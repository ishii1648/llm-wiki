---
title: Design Doc(ソフトウェア設計ドキュメント)
type: concept
aliases: [design document, software design document, ソフトウェア設計書, デザインドック]
tags: [process, documentation, planning, software-engineering]
created: 2026-06-27
updated: 2026-07-01
sources:
  - raw/articles/write-an-effective-design-doc.md
related:
  - "[[michael-lynch]]"
  - "[[spec-driven-development]]"
---

## 概要

実装前に**難しい意思決定**を整理し、チーム/関係チーム間で合意形成するためのドキュメント。
[[michael-lynch]] による経験則(Google/Microsoft 出身)では、文書化すべき決定は「間違えたときのコスト」で判断する。**high-cost な決定は書く、low-cost(あとで数時間で直せる)決定は書かない**。実装の完全な仕様化を目指すと「設計段階で実装したのと同じ」になり目的を失う。

## 書くべきかの判断軸

以下のいずれかに該当すれば書く価値が高い。2つ以上なら「ほぼ確実に」書くべき。

- 複数人で実装を協調するか
- フルタイムで 3 ヶ月以上かかるか
- 本番で数年運用するか
- クロスチーム協業を伴うか
- 要件が曖昧か
- 設計段階で防げる致命的リスク(security/legal)があるか

投資量は固定ルールなし。1 ページの簡易版から 5 チームの sign-off を要する 50 ページ版までスペクトラム。**ゼロが正解な場合もある**。

## 「間違えたときのコスト」原則

> "what's the cost of getting it wrong?"

- **書くべき例**: 言語選択(C++ vs Ruby on Rails)。20 万行書いた後の rewrite は実質不可能で、二言語併存の保守負債を負う。
- **書かない例**: ページネーション UI(全件表示 vs "Load more")。間違えても数時間で直せる。レビューサイクルを費やす価値もない。

## コンポーネント一覧(23 節)

全節を毎回入れる必要はなく、案件に応じて取捨選択する。

### メタ情報

| 節 | 役割 |
|---|---|
| **Title** | 短く(発音しやすい)・固有(区別がつく)・暗示的(意図が伝わる)。例: caching 層なら `RecencyBank`、悪例は `Project Flying Silver Horse` |
| **Metadata** | 著者(名+email)、作成日、authoritative URL(`http://go/recency-bank` 等の shortlink を含む)、status |
| **Objective** | 1 文。1 ページ目に。実装と無関係なステークホルダーでも理解できる平易な言葉で |
| **Background** | なぜこのプロジェクトを今やるのか/解決する問題/過去の試行 |
| **Related documents** | test plan、関連システムの design doc、前イテレーションの design doc |

### スコープ

| 節 | 役割 |
|---|---|
| **Goals** | **impact** で書く(実装詳細でなく)。悪例:「Kubernetes を導入」/ 良例:「デプロイ起因の outage を最小化」 |
| **Non-goals** | 読者が範囲内と誤解しそうな目標を**明示的に**範囲外と宣言 |
| **Scenarios** | "Share as URL ボタン追加" だけだと伝わらない。完成形が実世界でどう動くかをユースケース列挙で見せる |
| **Diagrams** | 著者の頭の中の構造を共有する最速手段。**編集可能な形式で**(写真化された手書きホワイトボード図は禁忌)。推奨ツール: [Excalidraw](https://excalidraw.com/), [draw.io](https://www.drawio.com/), Google Drawings; programmatic では [Mermaid](https://mermaid.js.org/), [D2](https://d2lang.com/), Graphviz。LLM に diagram コードを書かせると効率良い。**ソース(描画ファイル/コード)へのリンク**を必ず置く |
| **Glossary** | 内部ツール名・略語の定義。ただし**読者が知っている語/インライン定義**の方がよく、glossary 行きはあくまで次善 |

### 運用契約

| 節 | 役割 |
|---|---|
| **Constraints** | 予算/クライアント/インフラ/依存から課される制約。例:「サーバが全部 RISC-V なので全コードが RISC-V で動くこと」 |
| **SLOs** | サービスがクライアント/ユーザに提供する**測定可能**な目標。SLA = SLO + 金銭ペナルティ。社内では普通 SLO のみ。"performant on mobile" のような曖昧表現を「<= 200ms」のような具体値に。典型軸: uptime/availability、latency、scale |
| **Monitoring / alerting** | SLO をどう**本番で測るか**。「サービス停止をどう検知?」「100x 遅くなったら?」「ほかに alert すべきイベントは?」 |
| **Timeline** | マイルストーン分割。各マイルストーンが**ステークホルダーに使える成果物**を生むように設計(例: dummy data の UI を先にクライアントに見せて要件齟齬を早期発見)。見積もり手法は Joel Spolsky の "Painless Software Schedules" を推奨 |

### 技術設計

| 節 | 役割 |
|---|---|
| **Interfaces** | UI(簡易スケッチで可、ピクセル単位の調整に立ち入らない)/API・CLI セマンティクス/ファイル形式 |
| **Dependencies / infrastructure** | 言語/実行ハードウェア・サービス/永続データの置き場。**変更コストの高い決定(言語・storage backend)に深く考え、置換容易な依存(メール送信サービス等)は軽く** |

### リスク

| 節 | 役割 |
|---|---|
| **Security** | 想定脅威/[attack surface](https://en.wikipedia.org/wiki/Attack_surface)(悪意あるデータの処理点)/trust boundary(低特権→高特権の流入点)。脅威が小さくても**根拠を文書化**するとレビュアーが見落としを発見しやすい |
| **Privacy** | 取り扱う機微データ/保持期間/アクセス権/at-rest と in-transit の暗号化 |
| **Legal considerations** | 金融/医療などの規制ドメインだけでなく、システム障害が違法行為になりうるかも検討。OSS リリースならライセンス選定理由 |
| **Logging** | log するイベント/log level/保管先/保持期間/アクセス権/log から除外すべき機微データ |

### 未決定事項

| 節 | 役割 |
|---|---|
| **Open issues** | 設計の穴、複数解で迷っている、情報不足のもの。各エントリで「問題/選択肢/直近の次ステップ」を書く |
| **Resolved issues** | 決着したら「決定+元の議論全文」を残してこちらに移す。**履歴を消さない**(将来の参照のため) |
| **Alternatives considered** | "Why didn't you do X?" への先回り回答。**簡潔に**(rejected 案を網羅的に書くのは overkill) |

## 設計原則(抽象)

1. **コスト非対称性で書き分ける**: 不可逆/高コストの決定だけを書面化。可逆/低コストはレビューサイクルにすら載せない。
2. **impact 駆動の目標**: ユーザ/チーム/会社への影響で goals を書く。実装の選択肢は手段にすぎない。
3. **測定可能性**: SLO は数値で、Monitoring はその検出手段とセットで定義する(でないと未検出のまま劣化する)。
4. **編集可能性**: 図表は再編集できる形式で。再編集不能な成果物は陳腐化したまま放置される。
5. **意思決定履歴の保全**: Open → Resolved は移し替え+元議論を残す。決定の**理由が消えない**ようにする。
6. **イントロが文脈なしで読めること**: design doc は対面説明なしで読まれる場面が多い。冒頭で前提が揃うようにする。

## レビューを回す(Driving Your Design Doc through Review)

design doc は**書いて終わりではない**。原本は「23 のコンポーネント」の後に、書き上げた doc をチームに共有しフィードバックを集める工程を明確に最後のステップとして置いている(出典 §"Driving Your Design Doc through Review")。

- 目的は、プロジェクトを**前に進める**有益なフィードバックを引き出すこと —— 些末な言い争いや混乱で停滞させないこと。
- doc の冒頭(Objective/Background)が**文脈なしで読める**ことがここで効く:多くのレビュアーは著者の口頭説明を聞く前に doc を読むため、必要な前提は1ページ目に揃っていなければならない(→ 上記「設計原則」6)。
- 具体的なフィードバック収集テクニックは、著者の別記事 *"How to Get Meaningful Feedback on Your Design Document"* にまとめられている(**本 wiki 未 ingest**。原本はこの記事へのリンクのみで、テクニックの詳細は含まない)。

> ⚠️ 出典範囲: 原本のこの節自体は導入文+別記事へのリンクで構成され、レビュー技法の詳細は当該別記事側にある。本ページはその事実関係のみを保持する(推測で技法を補わない)。

## 関連概念

- [[spec-driven-development]] — SDD は「コードでなく仕様を第一級成果物」とする AI 時代の派生形。design doc は実装前合意のための人間-人間ドキュメント、SDD spec は LLM への発注書・回帰の真実源という違い(両者は補完しうる)。
- [[michael-lynch]] — 本稿著者の OSS [`little-moments`](https://codeberg.org/mtlynch/little-moments) には著者本人による[公開 design doc 実例](https://refactoringenglish.com/excerpts/write-an-effective-design-doc/little-moments-design-doc/)がある(著者いわく「公開された high-quality な design doc は他に見たことがない」)。

## 出典

- raw/articles/write-an-effective-design-doc.md — Michael Lynch, "How to Write an Effective Software Design Document"(refactoringenglish.com, 2026-06-24)
