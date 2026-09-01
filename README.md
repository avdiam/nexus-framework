<!-- Version: 1.0.0 | Date: 2026-08-31 | Sprint: 112 | ISS-100 step 2.1 -->
<!-- Authored in the NEXUS dev repo at .nexus/tools/repo-root/README.md and copied to the -->
<!-- public repository root by .nexus/tools/export-dist.sh. Edit it there, never here.     -->

# NEXUS

**A markdown-based project management and development framework for AI-assisted work.**

NEXUS externalizes a project's entire state into structured markdown files that Claude loads at
the start of every conversation — sprint context, issue progress, design decisions, learned
patterns, system health. The result is continuity across any number of conversations, with an
assistant that remembers what you decided in conversation 12 and knows where to resume in
conversation 40.

It is free, open, and written in plain English. There is no proprietary format, no compiled code
and no black box — open any file and you will find instructions you and Claude can both read.

> The framework itself was built this way: **111 closed sprints, hundreds of conversations, zero context
> loss.** Every file in this repository was produced by NEXUS managing its own development.

The full explanation — architecture, methodologies, cognitive tools, the pattern system, the
health system — lives in the
**[NEXUS Framework Guide](plugins/nexus/project-template/.nexus/human-guides/nexus-framework-guide.md)**.
This page does not repeat it.

---

## Install

Two routes. Take the plugin route unless something stops you.

### Plugin route

In Claude Code, from any folder:

```
/plugin marketplace add avdiam/nexus-framework
/plugin install nexus@nexus
```

Then open your project and run the installer:

```bash
cd your-project
claude
```

```
/nexus:setup
```

**Restart Claude Code when it finishes.** This is not optional — Claude Code registers hooks at
launch, so the session you ran setup in has none of them. The
[Installation Guide](plugins/nexus/project-template/.nexus/human-guides/installation-guide.md)
explains why in full.

### Clone route

For Claude Code on the web, for setups where `/plugin` is unavailable, or if you would rather see
exactly what lands before it lands:

```bash
git clone https://github.com/avdiam/nexus-framework.git
```

The framework files live at `plugins/nexus/project-template/`. Copy `CLAUDE.md`, `.claude/`,
`.nexus/` and `.gitignore` into your project. The
[Installation Guide](plugins/nexus/project-template/.nexus/human-guides/installation-guide.md)
walks through every step the installer would otherwise have done for you.

### What you need

Claude Code (CLI, desktop app, an IDE extension, or the web app), a paid Claude plan, and Python 3
with PyYAML. NEXUS boots without Python, but token tracking and registry validation switch off and
it will tell you so. Details and the web-app caveats are in the Installation Guide.

---

## First conversation

Say `start`. On a fresh installation NEXUS detects it and walks you through four steps:

1. `/nexus-init-project` — creates state files and registries
2. `/nexus-setup-project` — defines vision, scope, deliverables, phases, constraints
3. `/nexus-generate-mvp` — breaks deliverables into a tracked issue backlog
4. `/nexus-organize-sprint` — plans your first sprint

Every conversation after that also begins with `start`. NEXUS loads your sprint state, detects the
phase, confirms it with you, and loads the right methodology.

New to it? Follow the
**[First Project Tutorial](plugins/nexus/project-template/.nexus/human-guides/first-project-tutorial.md)**.

---

## Guides

Fifteen guides ship inside the framework at
`plugins/nexus/project-template/.nexus/human-guides/`. Read them in journey order:

**Start here**

| Guide | For |
|---|---|
| [Framework Guide](plugins/nexus/project-template/.nexus/human-guides/nexus-framework-guide.md) | What NEXUS is and how it works — the canonical reference |
| [Installation Guide](plugins/nexus/project-template/.nexus/human-guides/installation-guide.md) | Both install routes, prerequisites, first boot |
| [Quick Start Guide](plugins/nexus/project-template/.nexus/human-guides/quick-start-guide.md) | The short path from install to working |
| [First Project Tutorial](plugins/nexus/project-template/.nexus/human-guides/first-project-tutorial.md) | A guided walkthrough of your first sprint |
| [Troubleshooting Guide](plugins/nexus/project-template/.nexus/human-guides/troubleshooting-guide.md) | When something does not behave |

**Working with it**

| Guide | For |
|---|---|
| [Navigation & Commands](plugins/nexus/project-template/.nexus/human-guides/navigation-and-commands-guide.md) | Every operation and how to reach it |
| [Project Management](plugins/nexus/project-template/.nexus/human-guides/project-management-guide.md) | Project lifecycle, scope, state |
| [Sprint Management](plugins/nexus/project-template/.nexus/human-guides/sprint-management-guide.md) | Planning, running and closing sprints |
| [Issue Lifecycle](plugins/nexus/project-template/.nexus/human-guides/issue-lifecycle-guide.md) | Analyze → implement → evaluate, end to end |
| [Methodology Files](plugins/nexus/project-template/.nexus/human-guides/methodology-files-guide.md) | How the phase methodologies are structured |

**Going deeper**

| Guide | For |
|---|---|
| [Pattern System](plugins/nexus/project-template/.nexus/human-guides/pattern-system-guide.md) | How NEXUS learns and reuses what worked |
| [Cognitive Tools](plugins/nexus/project-template/.nexus/human-guides/cognitive-tools-guide.md) | Mental models, problem-solving and strategic packs |
| [Architecture Quick Guide](plugins/nexus/project-template/.nexus/human-guides/architecture-quick-guide.md) | The system map at a glance |
| [Documentation System](plugins/nexus/project-template/.nexus/human-guides/documentation-system-guide.md) | How the guide library maintains itself |
| [Maintenance & Evolution](plugins/nexus/project-template/.nexus/human-guides/maintenance-and-evolution-guide.md) | Health monitoring and the ten maintenance operations |

---

## Repository layout

```
.claude-plugin/marketplace.json        the marketplace this repo publishes
plugins/nexus/
├── .claude-plugin/plugin.json         plugin metadata; version matches the release tag
├── skills/setup/                      /nexus:setup   — installs the framework into a project
├── skills/upgrade/                    /nexus:upgrade — reports what your install is missing
└── project-template/                  THE FRAMEWORK ITSELF — what gets copied into your project
    ├── CLAUDE.md                      the always-loaded harness
    ├── .claude/skills/                the operations
    ├── .claude/hooks/                 token tracking, YAML validation, backups
    └── .nexus/                        state, registries, patterns, templates, guides
```

Everything under `project-template/` is what lands in your project. The rest is packaging.

---

## Contributing

This repository is a **generated export** — it is regenerated from a private development
repository rather than edited in place. That changes how contributions work, and
[CONTRIBUTING.md](CONTRIBUTING.md) explains it: issues and pull requests are both welcome and
both read, but a merged change is ported upstream rather than merged directly.

Bugs and ideas have [templates](.github/ISSUE_TEMPLATE/). Start there.

---

## License

MIT — see [LICENSE](LICENSE). Fork it, adapt the methodology, add operations, rewrite the
behavioral preferences. NEXUS is a starting point, not a locked product.
