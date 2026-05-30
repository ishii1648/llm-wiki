---
title: Skills (AgentSkills)
type: concept
aliases: [Skills, AgentSkills, agent skills, スキル, SKILL.md]
tags: [strands, plugins, skills, progressive-disclosure]
created: 2026-05-30
updated: 2026-05-30
sources:
  - raw/articles/strands-skills.md
related:
  - "[[strands-agents]]"
  - "[[plugins]]"
  - "[[state-management]]"
  - "[[multi-agent-patterns]]"
---

## 概要
**Skills** は、システムプロンプトを肥大化させずにエージェントへ専門指示をオンデマンド提供する仕組み。`AgentSkills` プラグインは [Agent Skills 仕様](https://agentskills.io/specification)に従い、**progressive disclosure**(軽量メタデータだけを system prompt に注入し、完全な指示は agent が tool 呼び出しで有効化した時にロード)を行う。[[plugins]] の基盤上に構築される。

## 詳細

### 解決する問題
複雑タスクで system prompt が肥大化すると、(1) context window 圧迫、(2) 多数の無関係指示による混乱、(3) 保守困難、が起きる。Skills は指示を自己完結パッケージに分割し、必要な時だけ全文をロードする(リファレンスマニュアルを必要時に開くイメージ)。

### 3フェーズの動作
1. **Discovery**: 初期化時にスキルの metadata(name + description)を読み、`<available_skills>` XML ブロックとして system prompt に注入。agent は「何が使えるか」を全文ロードせず把握する。
2. **Activation**: agent が `skills` ツールを skill 名付きで呼ぶと、完全な指示・metadata・リソースファイル一覧が返る。
3. **Execution**: agent が指示に従う。リソースファイル(scripts/references/assets)へのアクセスには別途ツールが必要。

注入される XML の例:
```
<available_skills>
  <skill>
    <name>pdf-processing</name>
    <description>Extract text and tables from PDF files.</description>
    <location>/path/to/pdf-processing/SKILL.md</location>
  </skill>
</available_skills>
```
この XML は **invocation 前に毎回リフレッシュ**されるため、`set_available_skills` / `setAvailableSkills` での変更が即時反映される。有効化済みスキルは [[state-management]] の agent state に記録され、セッション永続化される。

### 使い方
`AgentSkills(skills=...)` はスキルソースとして、ファイルパス・親ディレクトリ・HTTPS URL・プログラム的 `Skill` インスタンスを受ける(Python は単一/リスト、TS は常に配列)。
```python
from strands import Agent, AgentSkills, Skill
plugin = AgentSkills(skills=[
    "./skills/pdf-processing",          # 単一スキルディレクトリ
    "./skills/",                        # 親ディレクトリ(SKILL.md を含む子を全ロード)
    Skill(name="custom-greeting", description="...", instructions="..."),
])
agent = Agent(plugins=[plugin])
```

- **リソースアクセス用ツールは別途提供**: `AgentSkills` は発見・有効化のみ担い、ファイル読取/スクリプト実行ツールは同梱しない(疎結合のため)。Python は `file_read`/`shell`、TS は `bash`/`fileEditor`(vended)が手軽。
- **プログラム的生成**: `Skill(...)` / `Skill.from_content(...)` / `Skill.from_file(...)` / `Skill.from_directory(...)`。
- **実行時管理**: `plugin.get_available_skills()` / `set_available_skills([...])` / `get_activated_skills(agent)`。

### SKILL.md フォーマット
スキル = `SKILL.md`(YAML frontmatter + markdown 指示)を含むディレクトリ。
```
---
name: pdf-processing
description: Extract text and tables from PDF files
allowed-tools: file_read shell
---
# PDF processing
You are a PDF processing expert. When asked to extract content from a PDF: ...
```
frontmatter フィールド: `name`(必須・小文字英数+ハイフン・1–64字)、`description`(必須・system prompt に出る)、`allowed-tools`(任意・空白区切り)、`metadata` / `license` / `compatibility`(任意)。

リソースディレクトリ標準構成: `scripts/`(実行スクリプト)/ `references/`(参照文書)/ `assets/`(テンプレート等)。有効化時にこれらの一覧が返る。

### Configuration
`skills`(必須)、`state_key`(既定 `"agent_skills"`)、`max_resource_files`(既定 20)、`strict`(既定 False; True で検証エラーを例外化)。

### 他アプローチとの比較
| アプローチ | 向くケース | トレードオフ |
|---|---|---|
| System prompt | 小さく常に関連する指示 | 能力が増えると肥大化 |
| Steering | 動的・context 依存の誘導/検証 | 設定が複雑 |
| **Skills** | modular・ドメイン特化の指示集 | 有効化に tool 呼び出しが要る |
| Multi-agent | 根本的に異なる役割/モデル | 複雑性・レイテンシ増(→ [[multi-agent-patterns]]) |

> 💡 専門カテゴリ別の Agent が `AgentSkills` に依存する構成(例: `T9sSkills` / `DatadogSkills` / `AWSInfraSkills` / `DatabaseSkills` / `OneloginSkills` / `ArgoCDSkills`)では、progressive disclosure と skill activation を先に把握することが理解の鍵。

## 出典
- `raw/articles/strands-skills.md` — progressive disclosure、3フェーズ動作、`<available_skills>` XML、`AgentSkills` の使い方、`Skill` API、SKILL.md フォーマット、リソースディレクトリ、Configuration、他アプローチ比較。
