---
title: Argo CD Application Controller のスケーリング
type: concept
aliases: [Argo CD application controller scaling, Argo CD scalability, ArgoCD スケーラビリティ]
tags: [argo-cd, gitops, kubernetes, scalability, sharding, qps, performance]
created: 2026-06-04
updated: 2026-06-04
sources:
  - raw/articles/argo-cd-scalability-testing-on-eks.md
related:
  - "[[argo-cd]]"
  - "[[gitops]]"
---

## 概要
Argo CD を大規模(10,000 アプリ規模)で動かす際のボトルネックは **application controller** にある。AWS が Amazon EKS 上で 10,000 アプリを 1 / 10 / 97 クラスタへデプロイした6実験から、効く設定と効かなかった設定が判明した。**最も効果が大きいのは (1) client QPS/burst QPS の引き上げ と (2) application controller のシャーディング**。reconciliation timeout も大規模では引き上げが必要。一方、公式が「最初に変えろ」と推奨する status/operation processors は本検証では効果が出なかった。

## 測定した2つの主要メトリクス
application controller の2大機能 = sync と reconciliation に対応する。

- **sync time(同期時間)**: 最初のアプリが resync され始めてから全アプリが resync されるまでの時間。
- **reconciliation queue clear out**: 1回の reconciliation サイクル内で全アプリの reconcile を完了できるか。完了できないと、前サイクルが終わる前に新サイクルが始まるリスク。
- (補助)**CPU 使用率**: 設定変更が controller に効いているかの指標。

## チューニング可能な設定(knob)

| 設定 | 場所 / キー | 役割 |
| --- | --- | --- |
| status / operation processors | `argocd-cmd-params-cm` ConfigMap: `controller.status.processors`(既定20)/ `controller.operation.processors`(既定10) | reconcile(status)キューと sync(operation)キューを捌くプロセッサ数 |
| client QPS / burst QPS | env: `ARGOCD_K8S_CLIENT_QPS` / `ARGOCD_K8S_CLIENT_BURST` | controller の k8s client が k8s API server へのリクエストを throttle し始める閾値。QPS=持続レート、burst=短時間の超過許容 |
| sharding(自動) | env: `ARGOCD_CONTROLLER_REPLICAS`(= replica 数 / シャード数) | クラスタ id のハッシュでクラスタを自動シャード |
| sharding(手動) | env: `ARGOCD_CONTROLLER_SHARD` + 管理対象クラスタ secret の `shard` フィールド | replica ごとに担当シャード番号を手動指定 |
| reconciliation timeout | `argocd-cm` ConfigMap: `timeout.reconciliation`(既定 3分) | controller が upstream git と downstream リソースの一貫性をチェックする間隔 |

> ⚠️ 注意: 既定の status/operation processors は記事本文では「10/20 status/operation processors」と表記される。設定キーは status=20→と operation=10→で対応がやや読み取りにくいが、要は2キューそれぞれのワーカ数。

## 実験環境
- Argo CD 本体: repo-server と api-server は各1台。Argo CD クラスタは **M5.4xlarge** EC2(リソース制約を排除する目的)。
- application クラスタ: **M5.large** EC2(アプリがリソースをほぼ消費しないため型は重要でない)。
- リソース quota は付与せず(CPU/メモリではなく controller 設定でメトリクスが律速されることを保証するため)。
- テストアプリ: 単一 GitHub リポジトリ上の **2 KB の ConfigMap** マニフェスト。単一 repo にしたのは ①controller だけに実験を絞るため ②全アプリを一斉に sync トリガするため(repo server への負荷は scope 外)。
- 監視: Prometheus / Grafana。

## 6つの実験と結果

| # | 実験 | 主な結果 |
| --- | --- | --- |
| 1 | ベースライン(reconciliation timeout 3分→6分) | 既定で 10,000 アプリ sync に **53分**。既定3分では reconciliation queue が 10K のまま捌けず、**360s(6分)**にすると 10K→0 に解消 |
| 2 | status/operation processors 変更 | 25/50・50/100・100/200 のいずれでも sync は **40〜41分**で**差なし**。ログに client-side throttling 警告が出現 → 実験3へ |
| 3 | client QPS / burst QPS | **最も効果大**。100/200 で 42分→**17分**、150/300 で **12分**、200/400 で **11分**。3分 timeout でも queue が捌けるように |
| 4 | application クラスタを10に増やす(シャーディング無し) | 約 **45分**。単一クラスタ(53分)よりわずかに速い程度 = クラスタ数増加だけでは改善しない |
| 5 | application controller を **10シャード**化 | 43分→**8分30秒**、3分 timeout でも queue 解消。ただしシャード間の負荷は不均等(自動割当のため担当クラスタ数に偏り) |
| 6 | 97クラスタ × 104アプリ + シャーディング | **8分**。実験5とほぼ同じ = クラスタ数を増やしても**シャーディングしない限り**性能優位は出ない |

> 注: アカウントのクラスタ上限により100ではなく97クラスタ(× 104アプリ)で実施。

## 効いた設定 / 効かなかった設定

- **効く**: client QPS/burst QPS の引き上げ(k8s API への呼び出し速度を上げる。同時に **k8s API server の監視**が必要)、application controller のシャーディング。
- **大規模で必須**: reconciliation timeout の引き上げ(アプリ数が多いと既定3分では queue を時間内に捌けない)。
- **本検証では効かず**: status/operation processors。公式ドキュメントは「スケール時に最初に変えるべき設定」とするが、本テストでは sync 時間・queue 解消とも不変。**人工的(2KB ConfigMap)な軽量ワークロード**ゆえの可能性があり、実アプリでの再検証が必要、と著者も留保。
- **単独では効かない**: application クラスタ数の増加(実験4・6)。

## 矛盾・要確認
> ⚠️ 矛盾(ドキュメント vs 実測): 公式 Argo CD ドキュメントは status/operation processors を「スケール時にまず変える設定」と推奨するが、本記事の実測では効果が観測されなかった(実験2・3)。著者は人工ワークロードが原因の可能性を挙げ、実アプリでの再検証を予定と明記。

> 本記事は2023-09時点の「early efforts(初期段階)」であり、より多数のクラスタとシャーディング機構の改善が将来課題として残されている(Conclusion)。

## 出典
- raw/articles/argo-cd-scalability-testing-on-eks.md(Test Parameters / Key Metrics / Environment / Experiments 1-6 / Conclusion)
