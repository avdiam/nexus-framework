# NEXUS Installation Guide
*Version: 4.1.0 | Date: 2026-08-31 | Sprint: 112 | Category: getting-started*

**Source files:** CLAUDE.md v5.16.0, plugin `setup` SKILL.md v1.3.0, nexus-start/SKILL.md v2.9.2, nexus-init-project/SKILL.md v3.0.0, nexus-setup-project/SKILL.md v5.2.0

Get NEXUS running in one conversation. No programming required.

There are two ways in. **The plugin route** installs NEXUS for you and is the one to take unless something stops you. **The clone route** copies the files by hand — it is the route for anyone who cannot use plugins, and the only route for Claude Code on the web.

---

## What You Need
[Section: What-You-Need]

### Claude Code

Any of the CLI, the desktop app, or an IDE extension (VS Code, JetBrains). All four surfaces run NEXUS.

**Claude Code on the web is supported with caveats.** It clones a GitHub repository into a cloud session, honours committed `settings.json`, hooks and agents, and has a shell — which is everything NEXUS needs. Three things differ, and all three are consequences of the same fact, that the session is not your machine:

- there is no `/plugin` command, so the web route is the **clone route**, always
- your project must be a **committed GitHub repository** — a local folder never reaches the session
- nothing persists unless you **commit and push**. A checkpoint that is not pushed is lost when the session ends

> ⚠️ **This ruling has not been executed end-to-end.** It is read from Anthropic's documented behaviour of cloud sessions, not from a run. The one thing that would falsify it is whether a cloud session emits the `[context:]` hook tag that NEXUS's token tracking reads; if it does not, the context percentage goes blank there and the 70% / 80% checkpoint prompts cannot fire. The test needs a published repository and is scheduled for the release that publishes one. Treat web support as *expected to work, unproven*, and prefer a local surface for your first project.

### A paid Claude plan

NEXUS spends a portion of every conversation's context on management and methodology. Free plans do not have headroom for both the framework and meaningful work.

### Prerequisites

Two of these are needed, one is a convenience. NEXUS installs and boots without any of them — it just runs with pieces switched off, and it tells you which.

| Prerequisite | Required | What breaks without it | Fix |
|---|---|---|---|
| **Python 3** | Yes | Token tracking and YAML validation stop. The context percentage reads `—` and the 70% / 80% checkpoint prompts never fire | Install from [python.org](https://python.org), then **restart Claude Code** |
| **PyYAML** | Yes | Registry-corruption protection is inactive. NEXUS keeps running, silently unguarded | `pip install pyyaml` |
| **jq** | No | Nothing. The JSON-parsing hooks fall back to Python automatically and behave identically | Optional speed-up: [jqlang.org/download](https://jqlang.org/download) |

Check what you have:

```bash
python3 --version || python --version
python3 -c "import yaml" || python -c "import yaml"
command -v jq
```

Two notes that catch people out. **Python 2 does not count** — the hooks use f-strings and raise `SyntaxError` under it, so if only `python` exists, confirm it reports 3.x. And **many Windows installs provide only `python`, not `python3`** — that is fine, NEXUS's hooks try both, which is why the commands above do too.

### The framework files

`https://github.com/avdiam/nexus-framework` — one repository that is simultaneously the plugin marketplace, the plugin, and the clone source.

> The repository is private until the first public release. If the link 404s, that release has not happened yet.

[/Section: What-You-Need]

---

## Which Route
[Section: Which-Route]

| Take the… | If |
|---|---|
| **Plugin route** | You are on the CLI, desktop app, or an IDE extension. This is the default |
| **Clone route** | You are on Claude Code **on the web**, or `/plugin` is unavailable or disabled in your setup, or you want to see exactly what lands before it lands |

Both routes install the same bytes. The difference is who does the work: on the plugin route a skill copies the files and runs the setup steps for you; on the clone route you run those same steps by hand. Everything the installer does is written out in Route B, so nothing is hidden from you.

[/Section: Which-Route]

---

## Route A — Plugin
[Section: Route-A-Plugin]

### 1. Add the marketplace and install

In Claude Code, from any folder:

```
/plugin marketplace add avdiam/nexus-framework
/plugin install nexus@nexus
```

This registers NEXUS with Claude Code once, for your account. You do not repeat it per project.

### 2. Open your project folder and run setup

```bash
cd your-project
claude
```

Then, in the conversation:

```
/nexus:setup
```

The installer names the directory it is about to write to and asks before writing anything. It then:

- refuses outright if `.nexus/` already exists — an existing install means `/nexus:upgrade`, not a re-install
- stops and offers a backup if you already have a `CLAUDE.md`, a `.claude/settings.json`, or a `.gitignore`, because a copy would silently overwrite them
- probes Python 3, PyYAML and jq and reports what it found, without blocking on anything missing
- warns if a `CLAUDE.md` exists in a *parent* directory (Claude Code loads those too, and one can conflict with NEXUS's boot)
- copies `CLAUDE.md`, `.claude/`, `.nexus/` and `.gitignore` into the folder
- writes `.claude/settings.local.json`
- offers to run `git init`, and commits nothing

### 3. Restart Claude Code — this one is not optional

When setup finishes it tells you to restart. Do it before typing anything else.

**Why**: Claude Code registers hooks **at launch**. NEXUS's hooks arrived in `.claude/settings.json` during the session you just ran setup in, so *that* session has none of them — no token tracking, no context percentage, and no automatic checkpoint at 70% or 80%. The very next thing you do is the first boot, which chains four operations and is the longest, most write-heavy conversation you will ever have with NEXUS. Running it with the safety net switched off is exactly the wrong trade.

This is a launch-order problem, not a settings problem. There is nothing to configure — the fix is to relaunch so the hooks are read at startup.

```bash
# exit Claude Code, then
claude
```

Then go to [First Boot](#first-boot).

[/Section: Route-A-Plugin]

---

## Route B — Clone
[Section: Route-B-Clone]

The clone route runs no installer, so every step below is one the plugin's `setup` skill would have done for you. None of them is optional.

### 1. Get the files

```bash
git clone https://github.com/avdiam/nexus-framework.git
```

The framework lives at `nexus-framework/plugins/nexus/project-template/`.

### 2. Copy the four items into your project

> ⚠️ **Read this before you run the copy — it is the one step on this route with no undo.**
> If your project already has a `CLAUDE.md`, a `.claude/settings.json`, or a `.gitignore`, the copy
> below **overwrites them silently** — no error, and you find out later. Back them up *first*:
>
> ```bash
> for f in CLAUDE.md .claude/settings.json .gitignore; do [ -f "$f" ] && cp "$f" "$f.pre-nexus"; done
> ```
>
> Then run the copy, and afterwards merge anything you want to keep *back* out of the `.pre-nexus`
> files — most often your own `.gitignore` rules. Merging has to happen after the copy, because the
> copy replaces the file you would be merging into.

```bash
cd your-project
cp -r ../nexus-framework/plugins/nexus/project-template/. .
```

The trailing `/.` is what copies the dotfile directories. You should end up with:

```
your-project/
├── CLAUDE.md            ← The harness: identity, protocols, routing, boot sequence
├── .gitignore           ← Ignores the machine-local files NEXUS generates
├── .claude/             ← What Claude Code loads
│   ├── skills/          ← The NEXUS operations
│   ├── hooks/           ← 6 small scripts (token tracking, backups, YAML validation)
│   ├── agents/          ← Sub-agent definitions
│   └── settings.json    ← Wires the hooks up
└── .nexus/              ← The framework's data
    ├── active/          ← State files and registries
    ├── templates/       ← Blueprints (including 13 domain profiles)
    ├── patterns/        ← Pre-populated knowledge library
    ├── memory/          ← Cross-sprint knowledge index
    ├── human-guides/    ← These guides
    └── ...
```

Verify before continuing:

```bash
ls -a | grep -E '^(CLAUDE\.md|\.nexus|\.claude|\.gitignore)$'
```

All four must be there. **All four are required** — `.nexus/` alone is just data, `CLAUDE.md` is what tells Claude how to read it, and `.claude/` is where the operations live.

> If you took backups above, this is where you merge from them — your `.gitignore` rules go at the head of the new file, above the NEXUS block. Read the result back and confirm every original rule survived.

### 3. Restamp the changelog registry

```bash
touch .nexus/active/registries/changelog-registry.yaml
```

**Why**: `cp -r` stamps every copied file with the copy time in directory-walk order, and `.nexus/active/registries/` happens to land before `.claude/skills/`. NEXUS's boot compares that registry's timestamp against every framework file, so without this line your first real boot reports ~108 files "newer than" the registry — a staleness warning manufactured entirely by the copy, and one that the first checkpoint does not clear.

### 4. Write `.claude/settings.local.json`

```bash
mkdir -p .claude
cat > .claude/settings.local.json <<'EOF'
{
  "env": {
    "CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS": "50000"
  }
}
EOF
```

**Why**: NEXUS's `CLAUDE.md` is large. Without this setting Claude Code truncates the read at roughly 10K tokens and boot loads a partial harness — the most confusing failure a new install can have, because nothing errors. It looks like NEXUS, and half the protocols are simply absent.

If the file already exists, add the `env` key to it rather than replacing it. It is git-ignored on purpose: it is per machine and per clone, so it never travels with the repository, and every fresh clone needs it written again.

### 5. Check for a parent `CLAUDE.md`

```bash
d=$(pwd); while [ "$d" != "/" ] && [ "$d" != "$(dirname "$d")" ]; do d=$(dirname "$d"); [ -f "$d/CLAUDE.md" ] && echo "parent CLAUDE.md: $d/CLAUDE.md"; done
```

If one turns up, you do not have to move it — just know it is loaded alongside NEXUS's and can conflict at boot. Launching Claude Code from the project folder directly is usually enough.

### 6. Initialise git if you want it

```bash
git init
```

Optional. NEXUS's checkpoints commit your sprint state, so version control is recommended and not required. Do not commit yet — the first boot writes the state files, and that is the commit worth having.

### 7. Open Claude Code — after the files are in place

```bash
claude
```

**Order matters here for the same reason it matters on the plugin route**: Claude Code registers hooks at launch. Because you copied `.claude/` *before* launching, the hooks are read at startup and token tracking works from your first turn. If Claude Code was already open in this folder while you were copying, quit and relaunch it now.

[/Section: Route-B-Clone]

---

## First Boot
[Section: First-Boot]

Both routes converge here. Start a conversation and type anything — "start", "hi", or "hello":

```
You: start
```

NEXUS reads its state file, sees `_project_lifecycle: not-defined`, and recognises a fresh installation. Instead of the normal startup header it runs the guided setup chain:

1. **`/nexus-init-project`** — creates state files and registries from templates. Automatic, a few seconds
2. **`/nexus-setup-project`** — an interactive wizard: what type of project this is (13 domain types), your vision and scope, your deliverables, the phases the work goes through, constraints and success metrics
3. **`/nexus-generate-mvp`** — turns your deliverables into a tracked issue backlog with dependencies
4. **`/nexus-organize-sprint`** — plans your first sprint from that backlog

Every step is guided. The wizard adapts to your project type — a software project gets different phase structures and deliverable types than an academic research project or a creative one.

This is a long conversation. It is also the one where the hooks earn their keep, which is why both routes above insist on launch order before you reach it.

> **If setup is interrupted**: start a new conversation. The lifecycle field stays `not-defined` until setup completes, so the next boot re-enters first-run and picks up where it stopped. `init-project` only creates files that do not already exist, so partial setups self-heal on retry.

> **Your first payoff**: your next conversation opens with a header showing your sprint, your focus, and exactly where to pick up. That moment — when Claude *knows* what you are working on without being told — is when the value clicks.

[/Section: First-Boot]

---

## What Happens Next
[Section: What-Happens-Next]

Every conversation after setup opens with a compact header:

```
You: start

NEXUS · Sprint #001 · Conv #2
Analysis (/nexus-analyze) · Control: Balanced · Opus 5 [1M]
Focus → Analyze ISS-001 — first issue of the sprint
Context: — (awaiting first hook) · 💡 "show menu" for operations
```

Four lines: where you are, what phase you are in and how much control you asked for, what you are picking up, and how much context you have. A fifth `⚠` line appears only when something actually needs attention.

> `Control: Balanced` is your **Control Level** — how often NEXUS stops to ask before acting. You set it at the start of every conversation. The three levels are explained in [The Three Unbreakable Principles](nexus-framework-guide.md#the-three-unbreakable-principles).

From here, say **"work on ISS-001"** and NEXUS walks you through analysis, then implementation, then evaluation, loading each phase's methodology just in time.

For a walkthrough of building a project end to end, see the [First Project Tutorial](first-project-tutorial.md).

[/Section: What-Happens-Next]

---

## Installing NEXUS Into Another Project
[Section: Another-Project]

Each NEXUS installation is self-contained: its own state, issues, patterns and history, evolving independently. To manage a second project, install into that folder the same way you installed into the first — `/nexus:setup` run there, or the clone route repeated. There is nothing to reconfigure and nothing shared between them; the project root *is* the folder you opened.

The plugin is registered once for your account, so on the plugin route a second project is one command: open the folder, run `/nexus:setup`, restart.

You can keep a project on a cloud drive (Google Drive, Dropbox, OneDrive) and work on it from several machines — open the same synced folder and pick up where you left off. NEXUS supports one user across many projects and machines; it does not yet support multiple users collaborating on one project.

> `/nexus:upgrade` compares an existing installation against the plugin's current copy and reports what differs. Use it to refresh an install; never re-run `/nexus:setup` over one, which is why setup refuses.

[/Section: Another-Project]

---

## Troubleshooting
[Section: Troubleshooting]

### The context percentage reads `—` and never updates

The hooks did not register. Almost always launch order: `.claude/settings.json` arrived after Claude Code started. Quit and relaunch in the project folder. If it persists, you are missing Python 3 — check with `python3 --version || python --version` and see the [prerequisites](#prerequisites).

### `/plugin marketplace add` fails or `/plugin` does not exist

Take the [clone route](#route-b--clone). It installs the same files and needs no plugin support. This is expected on Claude Code for the web.

### Nothing NEXUS-like happens when I type "start"

Claude Code did not load `CLAUDE.md`. Check that it sits at the root of the folder you opened, spelled exactly that way (case-sensitive on macOS and Linux), and not one level deeper in a cloned subfolder.

### Boot behaves oddly, or protocols seem to be missing

`.claude/settings.local.json` is missing or lacks the read cap, so `CLAUDE.md` was truncated. This is silent — nothing errors, NEXUS just runs with half its protocols absent. Re-do [step 4 of the clone route](#4-write-claudesettingslocaljson); it applies to both routes, since the file is git-ignored and never travels with a repository.

### Boot says "sprint-state.md not found"

The file belongs at `.nexus/active/states/sprint-state.md`. If it is missing, the copy was incomplete — re-run the copy on the clone route, or `/nexus:upgrade` on the plugin route. If the folder looks right, check you opened the folder that directly contains `CLAUDE.md`.

### Boot doesn't detect a fresh install

Check that `_project_lifecycle: not-defined` is present in `sprint-state.md`. If the field is missing entirely, boot treats the installation as an already-active project.

### The first real boot shows a staleness warning about the changelog registry

The `touch` step was skipped. Run it now and the warning clears:

```bash
touch .nexus/active/registries/changelog-registry.yaml
```

### `/nexus:setup` refuses to run

It found `.nexus/` already there. That is the guard working — copying over a live install destroys sprint state, issues and patterns. Use `/nexus:upgrade` to compare and refresh. If the folder really is disposable, remove `.nexus/` yourself and re-run.

### Context feels tight during work

NEXUS spends part of every conversation on management. At **70%** it recommends a checkpoint; at **80%** it saves automatically and keeps going. Saving a checkpoint never ends a conversation — it writes progress to disk so the next one resumes exactly where this stopped.

[/Section: Troubleshooting]

---

## Going Deeper
[Section: Going-Deeper]

| Guide | What you'll learn |
|-------|-------------------|
| [First Project Tutorial](first-project-tutorial.md) | Guided walkthrough from setup to first sprint |
| [Quick Start Guide](quick-start-guide.md) | Core concepts and essential commands in 5 minutes |
| [NEXUS Framework Guide](nexus-framework-guide.md) | Complete system reference |
| [Architecture Quick Guide](architecture-quick-guide.md) | System structure in 5 minutes with diagrams |
| [Project Management Guide](project-management-guide.md) | Project lifecycle, multi-project workflow |
| [Troubleshooting Guide](troubleshooting-guide.md) | Comprehensive problem-solving reference |

[/Section: Going-Deeper]

---

*Need help? Say "help" in any NEXUS conversation for context-aware assistance.*
