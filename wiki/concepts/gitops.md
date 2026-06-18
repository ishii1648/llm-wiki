---
title: GitOps
type: concept
aliases: [GitOps]
tags: [gitops, kubernetes, cncf, delivery, declarative]
created: 2026-06-04
updated: 2026-06-04
sources:
  - raw/articles/argo-cd-scalability-testing-on-eks.md
related:
  - "[[argo-cd]]"
---

## 概要
GitOps は、コンテナ化アプリケーションのデリバリにおいて git を desired state の単一の真実源(source of truth)とし、宣言的マニフェストへの変更をクラスタへ継続的に反映していくデプロイ運用のアプローチ。Kubernetes の普及とともに、GitOps プラットフォームを「at scale(大規模)」で運用したいという関心が高まっている(本文導入)。

## CNCF のツール
記事では GitOps 原則を実装する CNCF ツールとして以下が挙げられている。

- **[[argo-cd]]**(本記事の主題)
- **Flux**
- **Spinnaker**

## reconcile(調整)の考え方
GitOps ツールは「actual state(クラスタにデプロイ済みの実状態)」と「desired state(git 上のマニフェスト)」の差分を継続的に検出し、両者を一致させる reconcile を回す。Argo CD ではこの役割を application controller が担い、その reconcile を時間内に回しきれるかがスケーラビリティの鍵となる(→ [[argo-cd-controller-scaling]])。

> 本ページは AWS の Argo CD スケーラビリティ記事に現れた範囲での GitOps の言及をまとめたもの。GitOps の正式な定義(OpenGitOps の4原則等)は未収録。

## 出典
- raw/articles/argo-cd-scalability-testing-on-eks.md(GitOps への関心・CNCF ツール列挙・reconcile)
