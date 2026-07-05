# Using your Opencode Go subscription in Claude Code

June 14, 2026

Source: https://kkovacs.eu/opencode-go-with-claude-code/
Author: Kristof Kovacs

Author bio: Hello, I'm Kristof, a human being like you, and an easy to work with, friendly guy. I've been a programmer, a consultant, CIO in startups, head of software development in government, and built two software companies. Some days I'm coding Golang in the guts of a system and other days I'm wearing a suit to help clients with their DevOps practices.

## TL;DR:

```
export ANTHROPIC_DEFAULT_OPUS_MODEL=minimax-m3
export ANTHROPIC_DEFAULT_SONNET_MODEL=minimax-m3
export ANTHROPIC_DEFAULT_HAIKU_MODEL=minimax-m3
export CLAUDE_CODE_SUBAGENT_MODEL=minimax-m3

export ANTHROPIC_BASE_URL="https://opencode.ai/zen/go/"
export ANTHROPIC_AUTH_TOKEN=""
export ANTHROPIC_API_KEY="$OPENCODE_API_KEY"
```

You can use only the Anthropic-compatible models: check on [OpenCode Go's website](https://opencode.ai/docs/go/#endpoints) — you want the ones that have `@ai-sdk/anthropic` in the AI SDK PACKAGE column.

As of writing this (2026-06-14), these are the MiniMax and the Qwen models, the top ones being:

- minimax-m3
- qwen-3.7-plus
- qwen-3.7-max

Don't expect Opus-level performance out of them (maybe Opus a few months ago), but I'm a firm believer that if you can work with the cheaper models, then you will definitely be able to work with the expensive ones when you have to.

## Why would I want to do this?

For example, I'm not currently a Claude subscriber – when I need their models, I use them [through OpenRouter](https://openrouter.ai/docs/cookbook/coding-agents/claude-code-integration). But sometimes I'm interested in some new feature of their Claude Code harness, and this is the easiest (also, cheapest 😇) way to experiment with that.
