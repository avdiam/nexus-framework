# Navigation & Commands Guide
*Version: 2.2.0 | Date: 2026-08-31 | Sprint: 112*
*How to interact with NEXUS — menus, commands, and routing*

**Category**: system-reference
**Level**: beginner
**Description**: How to interact with NEXUS — menu interface, command routing, natural language triggers.

**Source files**:
- CLAUDE.md v5.16.0 (Command Recognition, Routing Map)
- .claude/skills/nexus-menu/SKILL.md v3.5.0 (menu structure)

---

## Two Ways to Navigate
[Section: Two-Ways-To-Navigate]

NEXUS accepts commands in two ways: **menus** and **natural language**. Both end up in the same place — the routing table maps everything to the right operation.

### Menus

Say **"show menu"** at any time to see the main command center:

```
NEXUS COMMAND CENTER
1. PROJECT    2. SPRINT    3. ISSUE    4. PATTERN
5. BRAINSTORM 6. COGNITIVE TOOLS  7. SYSTEM
8. HELP       9. DASHBOARD  0. Exit menus
```

Pick a number to open a sub-menu. Each sub-menu lists its operations with numbered options. Say **0** to go back. Menus are great for discovering what's available.

### Natural Language

Just say what you want. NEXUS recognizes intent and routes to the right operation:

- "create a new issue about the login bug" → create-issue
- "show me the sprint status" → sprint-status
- "help me understand patterns" → help
- "save my progress" → Checkpoint

You don't need exact phrasing. NEXUS scans for command triggers even when embedded in longer requests.

[/Section: Two-Ways-To-Navigate]

---

## Command Reference
[Section: Command-Reference]

### Project Commands

| Say this | What happens |
|----------|-------------|
| "init project" / "initialize project" | First-run initialization of an installation that **already has** the framework files |
| "install nexus" / "set up nexus here" / "new project" | Installs NEXUS into a folder that has no `.nexus/` yet — routes to the plugin `setup` skill (`/nexus:setup`), see the [Installation Guide](installation-guide.md) |
| "define project" / "setup project" | Project definition wizard |
| "update project parameters" / "change project vision" | Modify scope, vision, constraints |
| "generate mvp issues" / "create issues from deliverables" | Auto-generate issues from project deliverables |
| "project status" / "show project" | View project state and progress |
| "close project" / "archive project" | Complete and archive the project |

### Sprint Commands

| Say this | What happens |
|----------|-------------|
| "organize sprint" | Plan sprints, check queue health, fix problems |
| "sprint status" / "sprint capacity" | View progress, capacity analysis |
| "close sprint" | Formally close the current sprint |
| "move issue ISS-XXX" / "reallocate ISS-XXX" | Move issue between sprints |
| "go back" / "loop back" / "return to analysis" | Return to a previous phase |
| "reorganize queue" / "replan sprints" | Optimize the sprint queue |

### Issue Commands

| Say this | What happens |
|----------|-------------|
| "create issue" / "new issue" / "new bug" / "new feature" | Create a new issue (wizard) |
| "quick issue" / "log issue" | Quick issue creation |
| "work on ISS-XXX" / "analyze ISS-XXX" | Start or resume work on an issue |
| "update issue ISS-XXX" | Modify issue metadata |
| "close issue ISS-XXX" / "resolve issue" | Mark issue complete |
| "list issues" / "view issues" | Show all open issues |
| "show ready issues" | Filter: issues ready for next phase |
| "show blocked issues" | Filter: blocked issues |
| "read ISS-XXX" | Load an issue file into memory |
| "archive issues" | Archive completed issues |

### Pattern Commands

| Say this | What happens |
|----------|-------------|
| "show patterns" / "list patterns" | View all patterns |
| "create pattern" / "new pattern" | Create with 4Q validation gate |
| "view pattern PAT-XXX" | View a specific pattern |
| "apply pattern" / "match patterns" | Find and apply matching patterns |
| "update pattern PAT-XXX" | Track effectiveness |
| "merge patterns" / "find similar patterns" | Consolidation opportunities |
| "delete pattern" / "archive stale" | Remove or archive patterns |

### System & Maintenance

| Say this | What happens |
|----------|-------------|
| "save session" / "save checkpoint" | Save current progress |
| "continue work" | Resume from sprint-state |
| "show menu" / "main menu" | Display command center |
| "system health status" | View system health score |
| "maintenance status" | Check maintenance tracking |
| "maintenance menu" | Full maintenance operations menu |
| "show system health" / "health diagnostic" | Run system health check |
| "rollback" / "restore file" | Restore files to previous versions |
| "changelog scan" / "rebuild changelog" | Update version registry |
| "verify subsystem" | Deep verification of a domain |

### Documentation & Help

| Say this | What happens |
|----------|-------------|
| "help" / "how do I..." / "what is..." | Context-aware help |
| "browse docs" / "list guides" | Browse available documentation |
| "learning path" / "where do I start" | Guided documentation path |
| "check staleness" / "stale docs" | Check if guides are outdated |
| "dashboard" | Visual dashboard (issues, patterns, project, sprint, maintenance, documentation) |
| "create guide" / "generate guide" | Generate a documentation guide |

### Cognitive Tools

| Say this | What happens |
|----------|-------------|
| "load cognitive tools" / "load all tools" | Load entire cognitive toolkit |
| "load mental models" | Load all 6 mental models |
| "load first principles" | Load First Principles |
| "load systems thinking" | Load Systems Thinking |
| "load inversion thinking" | Load Inversion |
| "load decision trees" | Load Decision Trees |
| "load probabilistic thinking" | Load Probabilistic Thinking |
| "load analogical reasoning" | Load Analogical Reasoning |
| "load problem solving tools" | Load problem-solving category |
| "load adversarial review" / "challenge this" | Load adversarial review tool |
| "load blind spot check" | Load blind spot identification |
| "load hypothesis testing" | Load hypothesis-driven framework |
| "load root cause analysis" | Load root cause analysis |
| "load counterfactual reasoning" | Load counterfactual reasoning |
| "load strategic reflection" | Load strategic reflection tool |
| "what's loaded" / "show loaded tools" | Display currently loaded cognitive tools |

[/Section: Command-Reference]

---

## How Routing Works
[Section: How-Routing-Works]

When you say something, NEXUS processes it through this chain:

```
Your message
    ↓
Scan for command triggers (even embedded in longer text)
    ↓
Match against the routing map (CLAUDE.md [Section: Routing-Map])
    ↓
Load the matching skill (.claude/skills/nexus-{name}/SKILL.md)
    ↓
Execute step-by-step
    ↓
Return to conversation
```

You don't need to think about the mechanics — it happens automatically. Skills live at `.claude/skills/nexus-{name}/SKILL.md`; issues at `.nexus/issues/`; patterns at `.nexus/patterns/`; state files at `.nexus/active/states/`; registries at `.nexus/active/registries/`.

[/Section: How-Routing-Works]

---

## The Menu System
[Section: The-Menu-System]

### Main Menu → Sub-Menus

```
NEXUS COMMAND CENTER
├── 1. PROJECT     → init, setup, update params, generate MVP, status, close
├── 2. SPRINT      → status, organize/queue, checkpoint
│                    └── after status: move issues, close sprint
├── 3. ISSUE       → create, update, list, close, archive, work on
├── 4. PATTERN     → list, create, view, apply, update, merge, delete
├── 5. BRAINSTORM  → discuss / talk things through
├── 6. COGNITIVE   → mental models, problem-solving, strategic reflection
├── 7. SYSTEM      → health diagnostic, maintenance prediction, verification,
│                    pattern maintenance, registry cleanup, issue validation,
│                    backup optimization, rollback, changelog
├── 8. HELP        → help, browse docs, learning path, staleness check
└── 9. DASHBOARD   → issues, patterns, project, sprint, maintenance, documentation
```

### Sprint Menu Special Behavior

The Sprint menu has a two-tier structure. Options 1–3 show first. After viewing sprint status (option 1), an **actions submenu** appears with issue moving and sprint closing. This keeps the initial menu clean while making deeper operations available in context.

### No Active Sprint

When no sprint is active (after closing one, before organizing the next), menus adapt: sprint-specific options are hidden or redirect to "organize sprint" to set up the next one.

[/Section: The-Menu-System]

---

## Tips
[Section: Tips]

**Discovery**: Not sure what's available? Say "show menu" and browse. Each sub-menu shows all operations in that domain.

**Efficiency**: Natural language is faster once you know the commands. "work on ISS-042" is quicker than navigating menus.

**Embedded commands**: You can embed commands in longer messages. "I'd like to create a new issue about the broken login flow on mobile" will trigger create-issue and use your description as context.

**Memory**: Say "what's loaded" to see which cognitive tools are currently loaded.

**Cognitive tools on demand**: You don't need to load tools at bootstrap. Say "load first principles" or "challenge this" anytime during work.

**Dashboard**: "dashboard" gives you a visual overview of any domain — issues, patterns, project progress, sprint state, or maintenance health.

[/Section: Tips]
