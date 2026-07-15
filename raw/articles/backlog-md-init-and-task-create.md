# Backlog.md `init` and `task create` — hands-on verification (v1.48.0)

Reproduced locally on 2026-07-16 in a scratch git repository using the globally
installed `backlog` CLI (`backlog --version` → `1.48.0`). Commands, terminal
output, and resulting file contents recorded verbatim below.

## Commands

```bash
git init -q
backlog init "Demo Project" --defaults
```

## Resulting file tree (excluding `.git`)

```
.
./AGENTS.md
./backlog
./backlog/archive
./backlog/archive/drafts
./backlog/archive/milestones
./backlog/archive/tasks
./backlog/completed
./backlog/config.yml
./backlog/decisions
./backlog/docs
./backlog/drafts
./backlog/milestones
./backlog/tasks
```

## `backlog/config.yml` contents

```yaml
project_name: "Demo Project"
default_status: "To Do"
statuses: ["To Do", "In Progress", "Done"]
labels: []
date_format: yyyy-mm-dd
max_column_width: 20
default_editor: "vim"
auto_open_browser: true
default_port: 6420
remote_operations: true
auto_commit: false
filesystem_only: false
bypass_git_hooks: false
check_active_branches: true
active_branch_days: 30
task_prefix: "task"
```

## `AGENTS.md` (head)

```
<!-- BACKLOG.MD GUIDELINES START -->
<!-- backlog.md-instructions-version: 1.48.0 -->
<CRITICAL_INSTRUCTION>

## Backlog.md Workflow

This project uses Backlog.md for task and project management.

**For every user request in this project, run `backlog instructions overview` before answering or taking action.**

Use the overview to decide whether to search, read, create, or update Backlog tasks.

Before task lifecycle actions, read the matching detailed guide:
- `backlog instructions task-creation` before creating or splitting tasks
- `backlog instructions task-execution` before planning, changing status or assignee, adding a plan or implementation notes, or implementing task work
- `backlog instructions task-finalization` before checking acceptance criteria, writing final summaries, or moving tasks to terminal statuses

Use `backlog <command> --help` before running unfamiliar commands. Help shows options, fields, and examples.
```

## Task creation

```bash
backlog task create "Set up CI pipeline" -d "Add GitHub Actions for lint/test" --ac "Lint runs on PR,Tests run on PR" --plain
```

Output:

```
File: backlog/tasks/task-1 - Set-up-CI-pipeline.md

Task TASK-1 - Set up CI pipeline
==================================================

Status: ○ To Do
Ordinal: 1000
Created: 2026-07-15 15:52 (UTC)

Description:
--------------------------------------------------
Add GitHub Actions for lint/test

Acceptance Criteria:
--------------------------------------------------
- [ ] #1 Lint runs on PR,Tests run on PR

Definition of Done:
--------------------------------------------------
No Definition of Done items defined
```

Resulting file `backlog/tasks/task-1 - Set-up-CI-pipeline.md`:

```markdown
---
id: TASK-1
title: Set up CI pipeline
status: To Do
assignee: []
created_date: '2026-07-15 15:52'
labels: []
dependencies: []
ordinal: 1000
---

## Description
<!-- SECTION:DESCRIPTION:BEGIN -->
Add GitHub Actions for lint/test
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Lint runs on PR,Tests run on PR
<!-- AC:END -->
```

### Observed pitfall

Passing a comma-separated string to a single `--ac` flag (`--ac "Lint runs on PR,Tests run on PR"`) does **not**
split into two acceptance criteria — it produces one AC item containing the literal comma. Multiple criteria require
repeating the flag: `--ac "condition 1" --ac "condition 2"`.

## Empty directories after `init`

`backlog/completed`, `backlog/drafts`, `backlog/docs`, `backlog/decisions`, `backlog/milestones`, and all of
`backlog/archive/*` are created empty by `init` and populated later by their respective commands
(`backlog task create`, `backlog doc create`, `backlog decision create`, `backlog milestone create`, archive/cleanup
operations).
