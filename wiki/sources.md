# Source Ledger

ingest 済みソースの台帳。**冪等性チェックの唯一の基準**です。1行 = 1ソース。
ingest のたびに LLM が追記・更新します(過去行は再 ingest 時のみ書き換える)。

形式:
```
- <raw パス> | sha256:<先頭12桁> | <ingest 日 YYYY-MM-DD> | <波及ページ>
```

- **sha256**: ソース本文のハッシュ先頭12桁。`shasum -a 256 <path> | cut -c1-12` で算出。
  再 ingest 時にこの値が一致すれば「内容不変 = 何もしない」、不一致なら「改訂されたので該当ページを更新」と判定する。
- **波及ページ**: そのソースを出典に持つページを `[[page]], [[page]]` 形式で列挙。
  各ページ frontmatter の `sources:` と双方向で一致していること(lint がチェック)。

抽出例: `grep "^- raw/" wiki/sources.md`

---

- raw/articles/strands-agent-loop.md | sha256:be15de0cce4d | 2026-05-30 | [[agent-loop]], [[strands-agents]]
- raw/articles/strands-structured-output.md | sha256:094fbec732ad | 2026-05-30 | [[structured-output]]
- raw/articles/strands-state.md | sha256:2c2e8ced3778 | 2026-05-30 | [[state-management]]
- raw/articles/strands-conversation-management.md | sha256:e1fc5c6c143a | 2026-05-30 | [[conversation-management]]
- raw/articles/strands-custom-tools.md | sha256:1c87120b671b | 2026-05-30 | [[custom-tools]]
- raw/articles/strands-mcp-tools.md | sha256:004e291d25ac | 2026-05-30 | [[mcp-tools]], [[model-context-protocol]]
- raw/articles/strands-plugins.md | sha256:ef258ccdafd8 | 2026-05-30 | [[plugins]], [[strands-agents]]
- raw/articles/strands-skills.md | sha256:7ef770865966 | 2026-05-30 | [[agent-skills]]
- raw/articles/strands-graph.md | sha256:a05873c04315 | 2026-05-30 | [[graph-multi-agent]], [[graph-swarm-hybrid]]
- raw/articles/strands-swarm.md | sha256:330eefbcc733 | 2026-05-30 | [[swarm-multi-agent]], [[graph-swarm-hybrid]]
- raw/articles/strands-multi-agent-patterns.md | sha256:6cdf66d01a13 | 2026-05-30 | [[multi-agent-patterns]], [[graph-swarm-hybrid]]
- raw/articles/strands-evals-quickstart.md | sha256:19eead1a4ac5 | 2026-05-30 | [[strands-agents-evals]]
- raw/articles/strands-evals-evaluators.md | sha256:c6a6668ebe2a | 2026-05-30 | [[evaluators]]
- raw/articles/strands-evals-experiment-management.md | sha256:e6397ada3e96 | 2026-05-30 | [[experiment-management]]
