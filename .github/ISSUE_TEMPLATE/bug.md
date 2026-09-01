---
name: Bug report
about: Something in NEXUS behaves differently than the guides say it should
title: ''
labels: bug
assignees: ''
---

<!-- Version: 1.0.0 | Sprint: 112 | ISS-100 step 2.1 -->

## Two checks first

Most reports resolve here. Please confirm both:

- [ ] I restarted Claude Code after installing (hooks register at launch — without a restart there
      is no token tracking and no automatic checkpoint)
- [ ] `python3 --version` (or `python --version`) reports 3.x, and `python -c "import yaml"` works

## What happened

<!-- What Claude did. -->

## What you expected

<!-- What the guides say should have happened. Link the guide and section if you can. -->

## How to reproduce

NEXUS is a behavioral framework, so the conversation shape matters more than a stack trace.

1. Install route used: <!-- plugin / clone -->
2. What you typed:
3. What NEXUS did:

**Startup header** — paste it verbatim, including any `⚠` line:

```

```

## Environment

| | |
|---|---|
| Claude Code surface | <!-- CLI / desktop app / IDE extension / web --> |
| Model and context window | <!-- e.g. Opus 5 [1M] — the startup header's second line --> |
| OS | |
| NEXUS version | <!-- the `*Version:*` line at the top of your CLAUDE.md --> |
| Python 3 / PyYAML / jq | <!-- e.g. 3.12 / yes / no --> |

## Anything else

<!-- Skill files you changed, a parent-directory CLAUDE.md, anything unusual about the install. -->
