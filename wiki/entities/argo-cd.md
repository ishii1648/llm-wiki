---
title: Argo CD
type: entity
aliases: [ArgoCD, Argo CD]
tags: [gitops, kubernetes, cncf, cd, delivery-tool]
created: 2026-06-04
updated: 2026-07-05
sources:
  - raw/articles/argo-cd-scalability-testing-on-eks.md
  - raw/articles/argo-cd-high-availability.md
related:
  - "[[gitops]]"
  - "[[argo-cd-controller-scaling]]"
  - "[[argo-cd-manifest-paths-annotation]]"
---

## 概要
Argo CD(ArgoCD)は、Kubernetes 上で動作する CNCF(Cloud Native Computing Foundation)の application delivery ツール。[[gitops]] の原則に基づき、git リポジトリ上の宣言的マニフェスト(desired state)とクラスタの実状態(actual state)を継続的に reconcile(調整)してデプロイを実現する。Flux / Spinnaker と並ぶ代表的な GitOps ツールとして言及される。

## アーキテクチャ:3つの主要コンポーネント
Argo CD は以下3つのコンポーネントから構成される(本文 "Background" 節)。

- **repository server(repo server)**: git ソースに接続してリポジトリを clone し、デプロイ前に application manifest を抽出する。
- **application controller**: 「世界の実状態(target Kubernetes クラスタにデプロイ済みのもの)」を「世界の desired state(repo server が git から取得したマニフェスト)」と能動的に reconcile する中核。**スケーラビリティの主役**であり、[[argo-cd-controller-scaling]] の対象。
- **API server**: エンドユーザーと Argo CD 内部の橋渡し。実状態と desired state の差分を提示し、デプロイの health 監視や手動 sync の再トリガを可能にする。

各コンポーネントは **Prometheus メトリクス**を emit し、設定 knob のチューニング時にこれを観測できる。

## スケーラビリティ取り組み(コンテキスト)
AWS は Argo CD OSS コミュニティと協働し、スケーラビリティ専門の **SIG(special interest group)** を Akuity・Intuit・Red Hat と共同設立。10,000 アプリを 1 / 10 / 97 リモートクラスタへデプロイする大規模試験を実施した。詳細な実験結果と推奨設定は [[argo-cd-controller-scaling]] を参照。

> このページは AWS のスケーラビリティ検証記事(2023-09-13)1本のみを出典とする初期ページ。Argo CD 一般の網羅的仕様(プロジェクト構造・RBAC・App of Apps 等)は未収録。

## パフォーマンス関連機能
repo server の manifest 生成は commit SHA 単位でキャッシュされるため、monorepo 構成(1リポジトリに複数 Application)では無関係な変更でも全アプリのキャッシュが無効化されうる。`argocd.argoproj.io/manifest-generate-paths` アノテーションでこれを回避し sync 時間を短縮する仕組みは [[argo-cd-manifest-paths-annotation]] を参照。

## 出典
- raw/articles/argo-cd-scalability-testing-on-eks.md(コンポーネント構成・SIG・試験概要)
- raw/articles/argo-cd-high-availability.md(Manifest Paths Annotation 節)
