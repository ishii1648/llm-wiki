---
title: Spec-Driven Development(SDD / 仕様駆動開発)
type: concept
aliases: [Spec-Driven Development, SDD, 仕様駆動開発, specification-driven development]
tags: [methodology, ai-assisted-development, agentic-development, software-engineering]
created: 2026-06-05
updated: 2026-06-05
sources:
  - raw/papers/one-developer-is-all-you-need.md
related:
  - "[[one-developer-is-all-you-need]]"
  - "[[one-person-squad]]"
  - "[[structured-output]]"
  - "[[design-doc]]"
---

## 概要
**Spec-Driven Development(SDD / 仕様駆動開発)** は、AI 支援のソフトウェア構築において、**コードではなく自然言語の仕様(specification)を第一級の工学的成果物**として扱う新興パラダイム(Rosa et al. 2026)。LLM コーディングアシスタント(GitHub Copilot, Devin など)が開発者の労力を「実装の記述」から「意図の宣言」(要件・インタフェース契約・事前/事後条件・受け入れ基準)へ移したことが前提。開発者の役割は、AI が曖昧さ最小でコードを生成・テスト・洗練できる程度に**精密な仕様を書くこと**になり、仕様自体が設計判断を記録し後の保守を支える耐久的成果物として残る。

## TDD との系譜と一歩上流への一般化
SDD は **Test-Driven Development(TDD)** に明確な系譜を持つ。TDD は実装前にテストを書くことでコードファースト workflow を反転させる。近年 TDD ループと LLM の組合せが生成コードの精度・信頼性を上げることが示されている(モデルに収束先の実行可能な受け入れ基準を与えるため)。SDD はこれを**一歩上流に一般化**する——テスト自体が「別途の著述ステップ」ではなく**仕様の出力**になり、仕様が実装と検証の双方を統べる。

## なぜ重要か: 律速を「仕様の質」に移す
SDD の核心は、出力品質の binding constraint を**モデル能力ではなく仕様の質**にすること。[[one-developer-is-all-you-need]] はこれを実証的に裏づけた:
- 詳細で曖昧さのない仕様は、supervised(Copilot)・autonomous(Devin)双方で、ほぼ無修正のコードを生んだ。
- 曖昧/不完全な仕様は、**どのツールでも使い物にならない出力**になった。
- ブラウンフィールドでは**未文書化のレガシー統合契約**が最大の under-specification 源。既存の振る舞い契約を仕様に明示しないと生成コードがそれを破り、rework が「より完全な事前仕様」のコストを上回った。

## 実務上のレバー
- **構造化プロンプトとしての仕様テンプレート**: アーキ判断・インタフェース契約・受け入れ基準・コンプライアンス制約を含む正準テンプレートを構造化プロンプトとして用い、設計フェーズと実行フェーズを分離(論文 Fig.1 のテンプレート)。
- **継続性(continuity)レバー**: SDD が生む仕様・決定記録・エージェント設定は、別のエンジニアや別のエージェント群がプロジェクトを途中から引き継げる程度に詳細。SDD はコード品質レバーであると同時に[[one-person-squad]]の単一障害点を緩和する継続性レバーでもある。
- **スキーマで型を固める**ことと相補的: 機械可読な出力契約は [[structured-output]](Pydantic/Zod スキーマ)の発想と地続き。SDD は人間可読な意図契約を上流に置く。

## 関連
- [[one-developer-is-all-you-need]] — SDD を一人スカッドで運用した実証事例。
- [[one-person-squad]] — SDD を成立基盤とするチーム構成。
- [[structured-output]] — 出力契約をスキーマで強制する補完的手法(Strands)。

## 出典
- raw/papers/one-developer-is-all-you-need.md(§II-A, §III, §V-B; Rosa et al. 2026 を引用)
