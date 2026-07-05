---
title: Argo CD Manifest Paths Annotation
type: concept
aliases: [manifest-generate-paths, argocd.argoproj.io/manifest-generate-paths, Manifest Paths Annotation]
tags: [argo-cd, gitops, kubernetes, performance, caching, monorepo]
created: 2026-07-05
updated: 2026-07-05
sources:
  - raw/articles/argo-cd-high-availability.md
related:
  - "[[argo-cd]]"
  - "[[argo-cd-controller-scaling]]"
  - "[[gitops]]"
---

## 概要
`argocd.argoproj.io/manifest-generate-paths` は Application リソースに付与するアノテーション。Argo CD は生成した manifest を**リポジトリの commit SHA 単位**でキャッシュしており、1つの git リポジトリを複数アプリで共有する構成(monorepo)では、無関係な変更のコミットでも同リポジトリの全アプリのキャッシュが無効化されてしまう。このアノテーションで「このアプリの manifest 生成が依存するパス」を宣言しておくと、無関係な変更では再生成・reconciliation をスキップしてキャッシュを使い回せる。

## 課題: commit SHA 単位キャッシュの副作用
Argo CD は "aggressively caches generated manifests and uses the repository commit SHA as a cache key" という設計であり、"A new commit to the Git repository invalidates the cache for all applications configured in the repository"。1つの git リポジトリに多数の Application を定義する monorepo 構成では、どこか1箇所の変更コミットのたびに**無関係な全アプリ**の manifest が repo-server 上で再生成される(Helm template / Kustomize build 等)。これが repo-server の負荷・処理待ちを増大させ、sync/reconciliation 全体を遅らせる原因になる。

## 仕組み
アノテーションにはセミコロン区切りでパスを列挙する。Argo CD は「最後にキャッシュした revision」と「最新コミット」を比較し、**変更ファイルがこのパスのいずれにも一致しなければ** application reconciliation をトリガせず、既存キャッシュを新しいコミットに対しても有効とみなす。

- **webhook あり**: webhook イベントのペイロードに含まれる変更ファイルリストと比較する。対応 git provider は **GitHub / GitLab / Gogs のみ**。
- **webhook なし(Argo CD v2.11 以降)**: webhook を設定しなくてもこの機能単独で利用可能(それ以前は webhook が前提条件だった)。

### パス指定の4パターン
| 指定方法 | 解決基準 | 例 |
| --- | --- | --- |
| 相対パス | Application の `source.path` からの相対 | `.` → `source.path` で指定したディレクトリそのもの |
| 絶対パス | リポジトリルートからの絶対パス(`/` 始まり) | `/guestbook` |
| 複数パス | `;` 区切りで併記 | `.;../shared` → 自ディレクトリ + 共有ディレクトリ |
| glob パターン | Go の [`filepath.Match`](https://pkg.go.dev/path/filepath#Match) 互換 | `/shared/*-secret.yaml` |

さらに、この機能が有効な場合は「アノテーションで指定したパスから算出される共通ルートパス」だけが CMP(Config Management Plugin)サーバへ送られ、リポジトリ全体を送る必要がなくなる(Application の `source.path` がルートとして選べる最深パス)。

## なぜ sync 時間が短縮されるのか
1. デフォルトでは commit SHA 単位のキャッシュ無効化により、monorepo で1コミット=**リポジトリ内全アプリの manifest 再生成**が走る。
2. このアノテーションで「自分に関係あるパス」を宣言すると、無関係な変更では reconciliation 自体がスキップされ、repo-server は**変更に関係するアプリだけ**の manifest を再生成すればよくなる。
3. repo-server の manifest 生成負荷(CPU・処理待ちキュー)が減ることで、[[argo-cd-controller-scaling]] が扱う application controller の reconciliation queue に積まれる「本当に処理が必要なアプリ」の数も減り、結果として sync 全体のサイクルが速く回る。

> [[argo-cd-controller-scaling]] は「reconciliation queue をどれだけ速く捌けるか」という controller 側のスループット改善([[argo-cd-controller-scaling]] の client QPS/シャーディング等)であるのに対し、本アノテーションは「そもそも queue に積む対象を減らす」という前段の最適化であり、両者は補完関係にある。

## 制限・注意点
- **アプリごとに別リポジトリを使う構成では恩恵なし**: 無関係コミットで他アプリのキャッシュが無効化される問題自体が起きないため。
- **外部 Helm values ファイル参照には効かない**: 参照先(リポジトリ外)での変更はこの比較の対象外。
- webhook 経由の比較は GitHub / GitLab / Gogs ベースのリポジトリのみサポート。

## 出典
- raw/articles/argo-cd-high-availability.md("Manifest Paths Annotation" 節: 課題の説明・4パターンのパス指定例・webhook 対応 provider・CMP サーバへの送信範囲)
