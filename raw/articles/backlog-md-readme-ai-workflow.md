# Backlog.md README — "Working with AI agents" / review checkpoints

Source: `README.md` (MrLesk/Backlog.md, main branch)
Retrieved verbatim via local clone on 2026-07-16.

## Header tagline

> AI agents write the code. You review the tasks: before, during, and after.

## Why Backlog.md in the AI era

AI agents can now produce more plausible code in an hour than you can carefully read in a day.
The bottleneck is no longer writing code. It's your attention. You can't meaningfully review
15,000 generated lines in one sitting, but you can read a screenful of task specs with acceptance
criteria before any code exists, and push back while a misunderstanding is still one sentence,
not a rebuilt feature.

Backlog.md structures agent work around **three review checkpoints**:

1. **Review the spec:** the agent decomposes your idea into tasks with descriptions, acceptance
   criteria, and milestones before implementation starts.
2. **Review the plan:** the agent researches your codebase and writes its implementation plan
   into the task. Approve it or steer before any code is written.
3. **Review the code:** one task = one context window = one PR. Diffs stay a size a human can
   actually read.

Afterwards, the completed tasks remain in Git as a permanent record of what was attempted and why,
legible to you, your team, and the next agent.

**Dogfooded:** nearly all of Backlog.md's own code is written by AI agents working through
Backlog.md itself. The full task ledger lives in this repo's backlog folder.

## Working with AI agents

This is the recommended flow for Claude Code, Codex, Gemini CLI, Kiro and similar tools, following the **spec‑driven AI development** approach.
After running `backlog init`, agents should start by running `backlog instructions overview`. Work in this loop:

**Step 1: Describe your idea.** Tell the agent what you want to build and ask it to split the work into small tasks with clear descriptions and acceptance criteria.

**🤖 Ask your AI Agent:**
> I want to add a search feature to the web view that searches tasks, docs, and decisions. Please decompose this into small Backlog.md tasks.

> [!NOTE]
> **Review checkpoint #1:** read the task descriptions and acceptance criteria.

**Step 2: One task at a time.** Work on a single task per agent session, one PR per task. Good task splitting means each session can work independently without conflicts. Make sure each task is small enough to complete in a single conversation. You want to avoid running out of context window.

**Step 3: Plan before coding.** Ask the agent to research and write an implementation plan in the task. Do this right before implementation so the plan reflects the current state of the codebase.

**🤖 Ask your AI Agent:**
> Work on BACK-10 only. Research the codebase and write an implementation plan in the task. Wait for my approval before coding.

> [!NOTE]
> **Review checkpoint #2:** read the plan. Does the approach make sense? Approve it or ask the agent to revise.

**Step 4: Implement and verify.** Let the agent implement the task.

> [!NOTE]
> **Review checkpoint #3:** review the code, run tests, check linting, and verify the results match your expectations.

If the output is not good enough: clear the plan/notes/final summary, refine the task description and acceptance criteria, and run the task again in a fresh session.

## Working without AI agents

Use Backlog.md as a standalone task manager from the terminal or browser.

(section continues with plain-CLI examples — not transcribed here; the point captured for this ingest is that the human-only path is a first-class, complete alternative, not a degraded fallback.)
