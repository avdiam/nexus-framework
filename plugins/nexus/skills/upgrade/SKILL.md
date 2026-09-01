---
name: upgrade
description: Compare this project's NEXUS framework files against the version bundled in the installed plugin, and report what differs. Read-only — reports differences, never writes them. Run when the user asks whether their NEXUS install is current.
---
*Version: 0.1.0 | Date: 2026-08-28 | Sprint: 112*

# NEXUS Upgrade — Contract Stub

⛔ **This skill is a contract, not an implementation.** It reports; it does not write. There is no
merge path here yet, and you must not improvise one. If the user asks you to apply an upgrade, say
plainly that automated merging is not implemented, show them the difference report, and let them
copy across whatever they choose.

Full implementation is tracked as **ISS-134**.

---

## Why a Report-Only Contract

A NEXUS project is **user-owned by design**. After `/nexus:setup`, every framework file lives in the
project and the user is free to edit it — many do, and the framework's own learning loop *rewrites*
`CLAUDE.md` behavioral preferences as sprints close. So the plugin's copy and the project's copy
diverge legitimately, and a blind overwrite would destroy earned local state:

| File class | Diverges because | Overwrite would destroy |
|---|---|---|
| `CLAUDE.md` | Learning loop edits `behavioral_preferences` at sprint closure | Every preference the user's own sprints earned |
| `.nexus/patterns/` | User creates and retires their own patterns | Their pattern library |
| `.nexus/active/` states, registries | Live sprint, issue, and pattern state | The entire project history |
| `.claude/skills/nexus-*` | Usually untouched — the genuine upgrade surface | Local customisations, if any |

That asymmetry is the whole reason upgrade is a separate skill from setup, and the reason its first
version reports rather than merges.

---

## The Contract

When invoked, this skill will:

1. **Locate both copies.** The plugin's golden copy is at `${CLAUDE_PLUGIN_ROOT}/project-template/`;
   the project's copy is the current working directory.

   > ⚠️ `CLAUDE_PLUGIN_ROOT` is a prompt substitution, not an environment variable — it is empty in
   > the shell. Never read it from `env` and never hardcode a cache or marketplace path.

2. **Confirm this is a NEXUS project.** If `.nexus/` is absent, stop: there is nothing to upgrade,
   and `/nexus:setup` is the skill they want.

3. **Compare, per file class**, and classify each difference rather than counting it — the
   classification is the deliverable:

   | Verdict | Meaning |
   |---|---|
   | `SAFE` | Plugin is newer, the project's copy is unmodified — a clean candidate to copy across |
   | `LOCAL EDIT` | The project's copy diverges from the version it was installed from — the user changed it, or the learning loop did |
   | `STATE` | Live project data. Never an upgrade candidate under any circumstances |
   | `NEW` | Present in the plugin, absent locally — usually a skill added since install |

4. **Report** the classification and stop.

5. **Never write.** No `cp`, no `Edit`, no `Write`, into the project or into the plugin cache
   (which is read-only anyway). The report is the entire output.

---

## Until ISS-134 Lands

Say so directly, and give the user the honest manual path:

> `/nexus:upgrade` is not implemented yet — it currently only describes what it will do.
> To update manually, compare your project's `.claude/skills/nexus-*` and `.nexus/templates/`
> against the plugin's `project-template/`, and copy across only the files you have not edited.
> Never copy `.nexus/active/` — that is your live sprint, issue, and pattern state.
