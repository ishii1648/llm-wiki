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

- raw/articles/strands-agent-loop.mdx | sha256:19cd408211a6 | 2026-05-30 | [[agent-loop]], [[strands-agents]]
- raw/articles/strands-structured-output.mdx | sha256:3f65936758ee | 2026-05-30 | [[structured-output]]
- raw/articles/strands-state.mdx | sha256:3e84de363530 | 2026-05-30 | [[state-management]]
- raw/articles/strands-conversation-management.mdx | sha256:029b6d701c10 | 2026-05-30 | [[conversation-management]]
- raw/articles/strands-custom-tools.mdx | sha256:475700eee5f9 | 2026-05-30 | [[custom-tools]]
- raw/articles/strands-mcp-tools.mdx | sha256:b12901d15aa3 | 2026-05-30 | [[mcp-tools]], [[model-context-protocol]]
- raw/articles/strands-plugins.mdx | sha256:216d1e42fccb | 2026-05-30 | [[plugins]], [[strands-agents]]
- raw/articles/strands-skills.mdx | sha256:130e17297e95 | 2026-05-30 | [[agent-skills]]
- raw/articles/strands-graph.mdx | sha256:60d70528507d | 2026-05-30 | [[graph-multi-agent]], [[graph-swarm-hybrid]]
- raw/articles/strands-swarm.mdx | sha256:cad3c0dc8015 | 2026-05-30 | [[swarm-multi-agent]], [[graph-swarm-hybrid]]
- raw/articles/strands-multi-agent-patterns.mdx | sha256:eaadf87ccd5a | 2026-05-30 | [[multi-agent-patterns]], [[graph-swarm-hybrid]]
- raw/articles/strands-evals-quickstart.mdx | sha256:b9e07b315a3f | 2026-05-30 | [[strands-agents-evals]]
- raw/articles/strands-evals-evaluators.mdx | sha256:83786def469d | 2026-05-30 | [[evaluators]]
- raw/articles/strands-evals-experiment-management.mdx | sha256:3584ecfdb839 | 2026-05-30 | [[experiment-management]]
- raw/articles/ai-code-review-assumes-an-author.md | sha256:ba21f8cd0a99 | 2026-06-03 | [[ai-code-review]]
