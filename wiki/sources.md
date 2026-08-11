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
- raw/articles/argo-cd-scalability-testing-on-eks.md | sha256:781b10ca47be | 2026-06-04 | [[argo-cd]], [[gitops]], [[argo-cd-controller-scaling]]
- raw/papers/one-developer-is-all-you-need.md | sha256:4983a3ce6186 | 2026-06-05 | [[one-developer-is-all-you-need]], [[one-person-squad]], [[spec-driven-development]], [[ai-productivity-task-vs-output]], [[ai-dlc-vs-spec-driven-development]]
- raw/articles/loop-engineering.md | sha256:818a59afada1 | 2026-06-10 | [[loop-engineering]], [[addy-osmani]]
- raw/papers/the-end-of-software-engineering.md | sha256:2c9494910273 | 2026-06-10 | [[the-end-of-software-engineering]], [[agentic-engineering]], [[agent-as-a-service]], [[ai-productivity-task-vs-output]], [[ai-dlc-vs-spec-driven-development]]
- raw/articles/ai-tokens-ninety-percent-garbage.md | sha256:6aa9b6624479 | 2026-06-11 | [[project-headroom]], [[tejas-chopra]], [[context-compression]], [[context-rot]]
- raw/articles/okf-spec.md | sha256:b9655e607346 | 2026-06-19 | [[open-knowledge-format]], [[knowledge-bundle]], [[okf-and-llm-wiki]], [[backlog-md-vs-okf]]
- raw/articles/write-an-effective-design-doc.md | sha256:e53c49985af4 | 2026-06-27 | [[design-doc]], [[michael-lynch]]
- raw/papers/writing-code-vs-shipping-code.md | sha256:078065ad164d | 2026-06-29 | [[writing-code-vs-shipping-code]], [[weak-link-hypothesis]], [[ai-coding-tool-generations]], [[ai-productivity-task-vs-output]]
- raw/articles/argo-cd-high-availability.md | sha256:d39383666816 | 2026-07-05 | [[argo-cd-manifest-paths-annotation]], [[argo-cd]]
- raw/articles/claude-code-scheduled-tasks.md | sha256:1b27199c442b | 2026-07-05 | [[loop-engineering]]
- raw/articles/claude-code-goal.md | sha256:efd54e63b3a2 | 2026-07-05 | [[loop-engineering]]
- raw/articles/claude-code-hooks-guide.md | sha256:a41151e102a1 | 2026-07-05 | [[loop-engineering]]
- raw/articles/claude-code-workflows.md | sha256:24fdbab78353 | 2026-07-05 | [[loop-engineering]]
- raw/articles/claude-code-tools-reference.md | sha256:e031778fec78 | 2026-07-05 | [[loop-engineering]]
- raw/articles/claude-code-channels-reference.md | sha256:3d8a8bac5bdc | 2026-07-05 | [[loop-engineering]]
- raw/articles/opencode-go-with-claude-code.md | sha256:4ed8c84b18d5 | 2026-07-05 | [[claude-code-non-anthropic-models]], [[opencode-go]], [[kristof-kovacs]]
- raw/articles/claude-code-channels-reference-ja.md | sha256:ce194d6afb6a | 2026-07-05 | [[loop-engineering]]
- raw/articles/claude-code-channels.md | sha256:5eecc4b146ec | 2026-07-10 | [[loop-engineering]]
- raw/articles/claude-code-channels-ja.md | sha256:733b5d97933e | 2026-07-10 | [[loop-engineering]]
- raw/articles/claude-code-remote-control.md | sha256:86fbf34e7c76 | 2026-07-10 | [[claude-code-remote-control]]
- raw/articles/claude-code-remote-control-ja.md | sha256:a36ed6cd6634 | 2026-07-10 | [[claude-code-remote-control]]
- raw/articles/mattpocock-grill-me-skill.md | sha256:6189dfceb730 | 2026-07-12 | [[grilling]], [[matt-pocock]]
- raw/articles/mattpocock-grilling-skill.md | sha256:5a35925d03a3 | 2026-07-12 | [[grilling]], [[matt-pocock]]
- raw/articles/mattpocock-grill-with-docs-skill.md | sha256:610d091047bc | 2026-07-12 | [[grill-with-docs]], [[matt-pocock]]
- raw/articles/mattpocock-domain-modeling-skill.md | sha256:152e2c97239a | 2026-07-12 | [[domain-modeling]], [[grill-with-docs]], [[matt-pocock]]
- raw/articles/backlog-md-manifesto.md | sha256:7e6c40d5eb3b | 2026-07-16 | [[backlog-md]], [[backlog-md-vs-okf]]
- raw/articles/backlog-md-task-example.md | sha256:79f3dd568f0a | 2026-07-16 | [[backlog-md]], [[backlog-md-vs-okf]]
- raw/articles/backlog-md-cli-instructions.md | sha256:c67543beea41 | 2026-07-16 | [[backlog-md]]
- raw/articles/backlog-md-init-and-task-create.md | sha256:0034acdff33b | 2026-07-16 | [[backlog-md]]
- raw/articles/backlog-md-readme-ai-workflow.md | sha256:665185e643c2 | 2026-07-16 | [[backlog-md]]
- raw/articles/backlog-md-agent-instructions-mechanism.md | sha256:63400c1d7038 | 2026-07-16 | [[backlog-md]]
- raw/articles/bringing-mcp-2026-07-28-to-claude.md | sha256:9361b2c39950 | 2026-07-29 | [[mcp-2026-07-28]], [[mcp-extensions]], [[model-context-protocol]], [[mcp-tools]]
- raw/articles/claude-code-self-hosted-environments.md | sha256:e51c7d536eb7 | 2026-08-07 | [[self-hosted-environment]]
- raw/articles/claude-code-self-hosted-environments-quickstart.md | sha256:6d3c8d4e1819 | 2026-08-07 | [[self-hosted-runner]]
- raw/articles/claude-code-self-hosted-environments-deploy.md | sha256:a6e6189e8f40 | 2026-08-07 | [[self-hosted-environment]], [[self-hosted-runner]]
- raw/articles/claude-code-self-hosted-environments-configuration.md | sha256:4ecbd984d8f7 | 2026-08-07 | [[self-hosted-runner-extensions]], [[session-identity-token]]
- raw/articles/claude-code-self-hosted-environments-testing.md | sha256:d0c8712a8a5b | 2026-08-07 | [[self-hosted-runner]]
- raw/articles/claude-code-self-hosted-environments-reference.md | sha256:e304b2cb4b32 | 2026-08-07 | [[self-hosted-runner]]
- raw/articles/claude-code-self-hosted-environments-identity.md | sha256:a695691cbc7b | 2026-08-07 | [[session-identity-token]]
- raw/papers/aidlc-method-definition.md | sha256:8a7b6cef429c | 2026-08-11 | [[ai-dlc]], [[intent-unit-bolt]], [[mob-rituals]], [[aidlc-prompt-kit]], [[ai-dlc-vs-spec-driven-development]]
