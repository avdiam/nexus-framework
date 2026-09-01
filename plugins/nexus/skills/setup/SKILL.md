---
name: setup
description: Install the NEXUS framework into this project — copies CLAUDE.md, .claude/ and .nexus/ from the plugin into the project root, writes settings.local.json, and checks prerequisites. Run once per project, only when the user explicitly asks to install NEXUS.
---
*Version: 1.3.0 | Date: 2026-08-31 | Sprint: 112*

# NEXUS Setup

Install the NEXUS harness into the current project, then hand off to its first boot.

**Flow**: Confirm target → Refuse if already installed → Probe prerequisites → Parent-CLAUDE.md check → Copy template → Write settings.local.json → Offer git init → Report

---

## Before You Start

⛔ **Run only when the user explicitly asks to install NEXUS.** This writes `CLAUDE.md`, `.claude/`
and `.nexus/` into the current directory. Never run it to "check" or "see" something.

⛔ **Never overwrite existing files.** STEP 1 is the guard, and it is not optional. If a later step
meets a conflict STEP 1 did not describe, stop and ask — do not resolve it yourself.

**Where the template lives.** The framework files ship inside this plugin at
`${CLAUDE_PLUGIN_ROOT}/project-template/`. That path is substituted into this text when the skill
loads, so it is already correct as written here.

> ⚠️ `CLAUDE_PLUGIN_ROOT` is a **prompt substitution, not an environment variable**. It is EMPTY in
> the shell. Never `echo` it from bash, never read it from `env`, never pass it to a script that
> expects it in the environment, and never hardcode a cache or marketplace path in its place —
> that path differs by install method and by machine. Use it only as written in this file.

---

## STEP 1: Confirm the Target, and Refuse an Existing Install

The install target is the **current working directory**. Say which directory that is, and confirm,
before writing anything:

> I'll install NEXUS into `{cwd}`. This adds `CLAUDE.md`, `.claude/`, `.nexus/` and `.gitignore`.
> Proceed?

Then check what is already there:

```bash
ls -a | grep -E '^(CLAUDE\.md|\.nexus|\.claude|\.gitignore)$' || echo "none present"
```

| Found | Meaning | Action |
|---|---|---|
| `.nexus/` exists | NEXUS is already installed here | **STOP. Do not copy.** Tell the user NEXUS is already present, and that `/nexus:upgrade` is the skill that compares their copy against this plugin's. Copying over a live install destroys sprint state, issues, and patterns. **This row has no install path — do not invent one.** Offering to move or back up `.nexus/` and install anyway converts a refusal into a destructive option; if the user believes the directory is disposable, they remove it themselves and re-run. (ISS-101 step 4.2 S2: a run offered exactly this.) |
| `CLAUDE.md` exists, no `.nexus/` | A non-NEXUS `CLAUDE.md` owns this project | **STOP and ask.** NEXUS needs the root `CLAUDE.md`. Offer to back theirs up to `CLAUDE.md.pre-nexus` and continue, or to abort. Never silently replace it. |
| `.claude/` exists, no `.nexus/` | The user has their own Claude Code config | **Check for collisions before copying.** `cp -r` merges directories but *overwrites files silently*. Run `ls .claude/settings.json .claude/hooks 2>/dev/null`. If `.claude/settings.json` exists, STOP and offer to back it up to `.claude/settings.json.pre-nexus` first — NEXUS's version carries the hooks and status line, and losing the user's own config to a silent overwrite is the worst outcome this skill can produce. |
| `.gitignore` exists, no `.nexus/` | The project already has ignore rules | **STOP and offer backup.** The template ships its own `.gitignore`, and `cp -r` overwrites it silently — the user's ignore rules vanish with no error, and the loss only surfaces later as unexpectedly tracked files. Offer `.gitignore.pre-nexus`, or offer to append the template's own entries to theirs instead of replacing — **read them from `${CLAUDE_PLUGIN_ROOT}/project-template/.gitignore` rather than from a list written here.** An enumeration in this file is a second home for the shipped file's contents and drifts from it: this row named four runtime entries when the template shipped five (`.nexus/.context-cache` was missing), which is the same one-short defect that made F-13 possible. Appending the file's real contents cannot be one short. Same failure mode as the `settings.json` row above. **If the user chooses MERGE, record the choice here and perform it at STEP 4 — see the sequencing note below.** (Added at ISS-101 step 4.2, finding F-13 — the 4.1 branch matrix enumerated three target states and this was the missing fourth.) |
| None of the above | Clean project | Continue to STEP 2. |

> ⚠️ **Sequencing — a remedy chosen here is not safe until STEP 4 has run.** STEP 4 copies the whole
> template with `cp -r`, which replaces `CLAUDE.md`, `.claude/settings.json` and `.gitignore` outright.
> A **backup** survives that, because `*.pre-nexus` is a different filename — take it here and it is done.
> A **merge** does not: it writes the user's rules into `.gitignore` itself, and STEP 4 then overwrites
> exactly that file. So decide the merge here, and **apply it at STEP 4, after the copy** — never before.
> (ISS-101 Validate, finding V-1: the merge branch passed its test only because the executing session
> happened to order it correctly; nothing in this file required that order.)

---

## STEP 2: Probe Prerequisites

NEXUS's hooks need a Python interpreter. Probe first, then report honestly — a missing prerequisite
is not a reason to abort the install, it is a reason to tell the user what will not work yet.

Run each probe and keep its result for the STEP 7 report:

```bash
python3 --version 2>/dev/null || python --version 2>/dev/null || echo "python MISSING"
```
```bash
{ python3 -c "import yaml" 2>/dev/null || python -c "import yaml" 2>/dev/null; } && echo "pyyaml ok" || echo "pyyaml MISSING"
```

The `python3` → `python` ladder is deliberate and matches what NEXUS's own hooks do. Many Windows
installs provide only `python`; probing `python3` alone reports PyYAML missing on a machine that
has it, and the user then "fixes" a problem they do not have.
```bash
command -v jq >/dev/null && echo "jq ok" || echo "jq absent"
```

| Prerequisite | Required? | What breaks without it | Remedy to print |
|---|---|---|---|
| Python 3 | **Yes** | Token tracking and YAML validation hooks fail; the status line stops updating | Install Python 3 from python.org, then restart Claude Code |
| PyYAML | **Yes** | Registry-corruption protection is inactive — NEXUS still runs, silently unguarded | `pip install pyyaml` |
| `jq` | No | Nothing. The hooks resolve a parser ladder and fall back to Python automatically | Optional speed-up: jqlang.org/download |

Python 2 does not satisfy the Python 3 requirement — the hooks use f-strings and raise
`SyntaxError` under it. If only `python` exists, confirm its version is 3.x before reporting it ok.

---

## STEP 3: Check for a Parent CLAUDE.md

Claude Code loads `CLAUDE.md` files hierarchically. A `CLAUDE.md` in a *parent* directory is loaded
in addition to the project's, and can conflict with NEXUS's boot protocol.

```bash
d=$(pwd); while [ "$d" != "/" ] && [ "$d" != "$(dirname "$d")" ]; do d=$(dirname "$d"); [ -f "$d/CLAUDE.md" ] && echo "parent CLAUDE.md: $d/CLAUDE.md"; done
```

If one is found, **warn — do not act on it**. It is not yours to move:

> ⚠️ A parent `CLAUDE.md` exists at `{path}`. Claude Code will load it alongside NEXUS's. If NEXUS
> behaves oddly at boot, launch Claude Code from this project folder directly, or remove the parent
> file. NEXUS's `CLAUDE.md` is self-contained and needs no workspace-level companion.

---

## STEP 4: Copy the Template

Copy the framework into the project root. The trailing `/.` copies the directory *contents*,
including dotfile directories.

```bash
cp -r "${CLAUDE_PLUGIN_ROOT}/project-template/." .
```

Verify the four top-level items landed:

```bash
ls -a | grep -E '^(CLAUDE\.md|\.nexus|\.claude|\.gitignore)$' || echo "none present"
```

Expect all four. If any is missing, name which one and stop — a partial copy is not a working
install. Re-running the copy is safe on a clean target; it is **not** safe once state exists.

**Now apply any MERGE deferred from STEP 1.** The copy has just replaced the user's `.gitignore`
with the template's, so this is the first moment a merge can survive. Read their rules back from the
backup you took, or from what you printed to them at STEP 1, and put them at the head of the file:

```bash
# only when the user chose merge at STEP 1
cat .gitignore.pre-nexus 2>/dev/null   # their rules, if a backup was taken
```

Write their rules above the template's block, read the result back, and confirm every original rule
is present before calling this done. A backup taken at STEP 1 needs nothing here — `.pre-nexus` is a
different filename and the copy never touched it.

Then restamp the changelog registry:

```bash
touch .nexus/active/registries/changelog-registry.yaml
```

`cp -r` stamps every file with the copy time in directory-walk order, so
`.nexus/active/registries/` lands *before* `.claude/skills/**`. Boot's derivation sweep compares
`changelog-registry.yaml`'s mtime against every framework file (edge E-12), so without this the
adopter's first rendered boot header reports ~108 sources "newer than" the registry — a staleness
warning manufactured entirely by the copy. Measured at ISS-101 step 4.2: 108 findings on *both*
install routes, identical, and the first `/nexus-checkpoint` does **not** clear it.

---

## STEP 5: Write settings.local.json

NEXUS's `CLAUDE.md` is large. Without this setting Claude Code truncates the read at roughly 10K
tokens, and boot silently loads a partial harness — the most confusing failure a new install can
have, because nothing errors.

The shipped `.claude/settings.json` already carries the hooks, the status line and the autocompact
override. This file carries only the read cap. It is git-ignored by convention, so it has to be
written per machine and per clone rather than travelling with the repository.

If `.claude/settings.local.json` does **not** exist, create it:

```json
{
  "env": {
    "CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS": "50000"
  }
}
```

If it **does** exist, read it, add the `env` key, and write it back — preserving every key already
there. Never replace a file the user owns.

Read the file back afterwards and confirm the key is present. Do not report this step as done on
the strength of having attempted it.

---

## STEP 6: Offer git init

Ask; do not assume. Some projects are already repositories, and some users do not want one.

```bash
git rev-parse --git-dir >/dev/null 2>&1 && echo "already a repo" || echo "not a repo"
```

If it is not a repository, offer: *"Initialise a git repository here? NEXUS checkpoints commit your
sprint state, so version control is recommended but not required."* On yes, run `git init`.

Do not commit anything here. The first commit comes later and is not this skill's to make: if
`/nexus-init-project` initialises the repository itself at first boot it commits the fresh install,
and otherwise the first `/nexus-checkpoint` does, with a message the user sees. Committing from
this skill would snapshot a tree whose lifecycle patch has not landed yet.

---

## STEP 7: Report and Hand Off

Report what actually happened. Every line must reflect a verified result, not an intention.

```
NEXUS installed → {cwd}
  Files      : CLAUDE.md, .claude/, .nexus/, .gitignore
  Settings   : settings.local.json {created | merged}
  Python 3   : {version | MISSING — hooks inactive}
  PyYAML     : {ok | MISSING — pip install pyyaml}
  jq         : {ok | absent (optional, Python fallback active)}
  Git        : {initialised | already a repo | skipped}
  {⚠ parent CLAUDE.md at {path}}

Next: RESTART Claude Code in this folder, then say "start".
```

Then stop. **Do not boot NEXUS yourself**, and do not let the user boot it in this session either —
the restart is load-bearing, not hygiene.

Claude Code registers hooks **at launch**. NEXUS's hooks arrived in `.claude/settings.json` during
this session, so this session is running without them: no `[context:]` tag, token tracking dead,
and the automatic checkpoint safety net (70% prompt, 80% mandatory save) cannot fire. The first
boot then runs `init-project` → `setup-project` → `generate-mvp` → `organize-sprint` in one go —
the longest, most write-heavy conversation an adopter will ever have — with that net switched off.

Measured at ISS-101 step 4.2: the plugin-route session reached 32% context with tracking reading
`—` throughout, while a clone-route session whose `.claude/` predated launch read `131K [13%]` from
its first turn. Same files, same tree; only launch order differed.

Starting here also skips the project-definition flow the fresh install is waiting for.

---

## If Something Fails

| Failure | Recovery |
|---|---|
| Copy fails partway | Report which items landed. On a clean target the copy is idempotent — fix the cause and re-run. If `.nexus/` already holds state, do **not** re-run; use `/nexus:upgrade`. |
| `${CLAUDE_PLUGIN_ROOT}/project-template/` not found | The plugin is registered but its files are missing. Ask the user to re-add the NEXUS marketplace and reinstall the plugin. Do not substitute a guessed path. |
| Cannot write `settings.local.json` | Say so explicitly, and say that boot will read a truncated `CLAUDE.md` until it is fixed. This one does not get buried in a summary. |
| `git init` fails | Non-fatal. Report and continue — NEXUS runs without git; only checkpoint commits are unavailable. |
