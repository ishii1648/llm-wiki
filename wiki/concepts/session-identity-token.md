---
title: セッション ID トークン(CLAUDE_CODE_SESSION_ACCESS_TOKEN)
type: concept
aliases: [session identity, session token, CLAUDE_CODE_SESSION_ACCESS_TOKEN, session_worker, ccr JWT]
tags: [claude-code, self-hosted, security, jwt, identity, authorization]
created: 2026-08-07
updated: 2026-08-07
sources:
  - raw/articles/claude-code-self-hosted-environments-identity.md
  - raw/articles/claude-code-self-hosted-environments-configuration.md
related:
  - "[[self-hosted-environment]]"
  - "[[self-hosted-runner]]"
  - "[[self-hosted-runner-extensions]]"
---

## 概要
[[self-hosted-environment]] のセッションは自社ネットワーク内で動くので、Claude が社内サービスを直接叩ける。そのサービス側が「この要求は本当に自社環境の Claude Code セッションから来たのか」「誰が始めたセッションか」を確かめるための仕組みが、環境変数 `CLAUDE_CODE_SESSION_ACCESS_TOKEN` に入る**署名付き JWT**。Anthropic が署名し、検証鍵は公開 JWKS エンドポイントで配布される。

## 詳細

### トークンが証明すること / しないこと
- **証明する**: Anthropic が「特定の環境の特定のセッション」に対して発行したこと、そしてそのセッションが**組織のユーザーによって作られたのか、組織のサービスキーで作られたのか**。
- **証明しない**: runner ホスト上の**どのプロセスが提示しているか**。トークンはセッション内の環境変数にあるので、**Claude が実行する任意のコード、セッションが起動する任意のツールや MCP サーバが読み取って提示できる**。

ここから2つの帰結が出る。第一に、`aud` を自社の環境 ID(`ccpool_...`)と突き合わせ、他組織の環境向けに発行されたトークンを拒否すること。第二に、トークンから導出するクレデンシャルは「作成ユーザーができること全部」ではなく「1つのコーディングセッションができるべきこと」にスコープすること。

### 形式
```
sk-ant-cc-<base64url header>.<base64url payload>.<base64url signature>
```
- JWT ライブラリに渡す前に `sk-ant-cc-` を剥がす。
- **Anthropic ホストの cloud session は `sk-ant-si-` prefix で別の鍵セットで署名される**ため、`sk-ant-cc-` 以外は拒否する。
- 署名アルゴリズムは `ES256`(P-256 + SHA-256)。ヘッダの `kid` で JWKS 内の鍵を選ぶ。

### サービス側での検証手順
鍵は `https://api.anthropic.com/v1/code/.well-known/jwks.json` で無認証公開。**鍵は定期ローテーションされるので単一鍵に pin しない**(旧鍵はそれで署名されたトークンが検証できる間セットに残る)。`Cache-Control: public, max-age=300` なので5分キャッシュで十分。

1. **prefix**: `sk-ant-cc-` で始まらなければ拒否し、剥がす。
2. **署名**: `kid` に一致する鍵で `ES256` を検証。`alg` が `ES256` でないものは拒否。**キャッシュに無い `kid` が来たら、拒否する前に1度だけ JWKS を再取得する**(ローテーション直後の新鍵)。
3. **issuer**: `iss` が厳密に `ccr` でなければ拒否。
4. **audience**: `aud` は配列。自社の環境 ID(`ccpool_...`)を含まなければ拒否。**この検査が他組織のトークンを弾く要**。
5. **role**: `ccr:role` が `session_worker` でなければ拒否。environment secret・runner トークン・work order も**同じ鍵セットで署名されている**が role が異なる。
6. **expiry**: 既定4時間、最大8時間。runner が期限前に更新してセッションへ渡すので、**1つのセッションが生涯に複数の有効なトークンを提示しうる**。
7. **identity**: `act.sub` が作成ユーザーの Anthropic ユーザー ID(`user:<id>` 形式)、`act.email` は記録があるときだけ入る。サービスキー由来のセッションにはユーザー ID が無いので、「識別情報が無い」で判定せず **`act.sub` が `user:` prefix を持つときだけユーザー作成と見なす**。

Node.js は `jose` の `createRemoteJWKSet` + `jwtVerify`、Python は PyJWT の `PyJWKClient` で、`issuer` / `audience` / `algorithms` を指定したうえで `ccr:role` を自前で確認する、というのが公式サンプル。

### 主なクレーム
| クレーム | 内容 |
|---|---|
| `iss` | 常に `ccr` |
| `sub` | `ccr:session:<session_id>` |
| `aud` | 配列。常に `anthropic-api` を含み、self-hosted では環境 ID も含む。**検証すべきは環境 ID の方** |
| `exp` / `iat` / `jti` | 期限・発行時刻・一意 ID |
| `ccr:role` | セッショントークンは常に `session_worker` |
| `ccr:session_id` / `ccr:pool_id` / `ccr:org_id` | セッション ID / 環境 ID / 組織 ID |
| `ccr:account_id` | 作成ユーザーの `user_...` ID(`act.sub` から `user:` を除いたもの)。`spawn-runner` hook の `CLAUDE_RUNNER_ACCOUNT_ID` や `--lock-to-account` と**文字列として一致する** |
| `account_email` / `organization_uuid` / `account_uuid` | 後方互換の重複クレーム。**削除されうるので依存しない** |
| `act` | RFC 8693 の委譲チェーン |

**email は当てにしない**: サービスキー由来のセッションでは `act.email` / `ccr:account_id` / `account_email` / `account_uuid` が欠ける。ユーザー作成セッションでも email は任意で、CLI から dispatch されたセッションは両方の email を持たないことがある。**identity のキーは `act.sub` か `ccr:account_id`**。

### `act` チェーン
`act` はセッションを作ったユーザーから、runner、環境、環境 secret を作った identity まで**委譲経路を丸ごと記録する**。作成ユーザーが最も外側なので `act.sub` がそのまま作成者。

| パス | 指すもの |
|---|---|
| `act.sub` | 作成ユーザー(`user:<id>`) |
| `act.email` | 作成ユーザーの email(記録がある場合のみ) |
| `act.attested_by.sub` | 上流 IdP(Google/Okta 等)が発行した subject。**自社システムの identity へマッピングするなら email より優先する** |
| `act.act.sub` | セッションを spawn した runner(`ccr:runner:<runner_id>`) |
| `act.act.act.sub` | 環境(`ccr:pool:<pool_id>`) |
| `act.act.act.act` | 環境 secret を作成した identity(ここで終端) |

### セッション内での検証(wrapper script)
wrapper script は JWT ライブラリを使う代わりに runner バイナリの `self-hosted-runner decode-token` を使える。トークンは「引数 → `CLAUDE_CODE_SESSION_ACCESS_TOKEN` → stdin」の順で読まれ、prefix を剥がし、JWKS に対して署名と有効期限を検証してクレームを JSON で出す。

> ⚠️ **`decode-token` が検査するのは署名と期限だけで、`iss` / `aud` / `ccr:role` は見ない**。認可判断がそれらに依存するなら、出力 JSON から読んで自分で比較する。

```bash
"$CLAUDE_RUNNER_CLAUDE_BIN" self-hosted-runner decode-token | jq -re '.act.attested_by.sub // .act.email // .act.sub'
```

`claude` を PATH 解決せず `CLAUDE_RUNNER_CLAUDE_BIN` を使う(runner と同じバイナリで decode するため)。`jq -r` だとクレーム欠落時に文字列 `null` を出して終了コード 0 になり不正値が下流へ流れるので **`jq -re`**。`--no-verify` は JWKS に到達できないオフライン調査専用。

### 派生クレデンシャルのスコープ
トークンは作成ユーザーを示すが、**そのユーザーが直接ログインしたのと同等に扱ってはいけない**。環境変数に置かれている以上、セッション内の任意のコードが読める。加えて**検証はオフラインで、一度検証を通ったトークンは `exp` まで有効なまま**であり、Anthropic はセッショントークンの失効フィードを公開していない。

したがって社内サービスがトークンを内部クレデンシャルに交換するときは:
- **能力を絞る**: コーディングタスクに必要な read/write だけを与え、そのユーザーが他所で持つ管理権限は与えない。
- **寿命を絞る**: トークンの `exp` 以下にバインドする。
- **セッションとして監査する**: ユーザー identity と並べて `ccr:session_id` と `jti` を記録し、特定セッションまで追跡できるようにする。

### 検証しない経路との使い分け
作成者の identity は**署名検証を伴わない**平文の環境変数としても2箇所に現れる:
- **orchestrator の `spawn-runner` hook**: `CLAUDE_RUNNER_ACCOUNT_EMAIL` / `CLAUDE_RUNNER_ACCOUNT_ID`。runner がまだ存在しない段階で使うもので、work order の署名自体は検証していない(environment secret で認証された orchestrator の接続経由で届くことを信頼している)。
- **wrapper script**: `CCR_SESSION_ACCOUNT_EMAIL`。ラベル用途向け。

**マシンイメージの選択のような orchestrator 側の判断には平文変数**を、**下流のサービスが独立した暗号学的証明を要る場面には `CLAUDE_CODE_SESSION_ACCESS_TOKEN`** を使う、という切り分け。

## 出典
- `raw/articles/claude-code-self-hosted-environments-identity.md`(Claude Code 公式ドキュメント)— トークンが証明すること/しないこと、形式と `sk-ant-si-` との区別、JWKS と7段階の検証手順、クレーム表と `act` チェーン、`decode-token` の限界、派生クレデンシャルのスコープ方針、検証しない環境変数との使い分け。
- `raw/articles/claude-code-self-hosted-environments-configuration.md`(同)— wrapper script が受け取るトークン系変数と、`decode-token` で作成者にスコープしたクレデンシャルを発行する実装例。
