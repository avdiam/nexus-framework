<!-- Version: 1.0.0 | Date: 2026-08-31 | Sprint: 112 | ISS-100 step 2.1 -->
<!-- Authored in the NEXUS dev repo at .nexus/tools/repo-root/CONTRIBUTING.md and copied to -->
<!-- the public repository root by .nexus/tools/export-dist.sh. Edit it there, never here.  -->

# Contributing to NEXUS

Contributions are welcome. Before you spend time on one, read the next section — it changes how
this repository works compared to most.

---

## This repository is a generated export

NEXUS develops itself. The framework you see here was built by NEXUS managing its own
development across 111 closed sprints, and that development happens in a **separate private
repository** that is never published — it carries 73 sprints of self-hosting archives, 221 closed
issues, large committed binaries and a git history approaching 200 MB, none of which belongs in
your project.

What you are looking at is regenerated from that repository by a manifest-driven export script,
with fresh history, every release. Concretely:

- **Nothing here is edited in place.** A commit made directly to this repository would be erased
  by the next export.
- **Pull requests are read, reviewed and answered** — but a change that is accepted gets
  **ported upstream** into the development repository, and reaches you in the following release.
  The pull request is then closed with a link to the release that carries it, not merged.
- **Your attribution survives the port.** Accepted changes are credited in the release notes.

This is stated plainly rather than discovered later, because the alternative — accepting a pull
request that the next export silently reverts — is worse for everyone.

**There is no CLA.** By opening a pull request you offer the change under the repository's
[MIT license](LICENSE), and that is the whole of it.

---

## Reporting a bug

Open an issue using the **Bug report** template. The one field that matters most is the
reproduction: NEXUS is a behavioral framework, so "Claude did X instead of Y" is only actionable
when it comes with the conversation shape that produced it — which skill was loaded, what the
startup header said, and what you typed.

Before filing, two quick checks that resolve a large share of reports:

1. **Did you restart Claude Code after installing?** Hooks register at launch. Without a restart
   there is no token tracking and no automatic checkpoint. The
   [Installation Guide](plugins/nexus/project-template/.nexus/human-guides/installation-guide.md)
   covers this.
2. **Do you have Python 3 and PyYAML?** Without them, token tracking and registry validation are
   switched off. The
   [Troubleshooting Guide](plugins/nexus/project-template/.nexus/human-guides/troubleshooting-guide.md)
   lists the symptoms.

## Suggesting an idea

Open an issue using the **Idea** template. Ideas that describe the *problem* rather than the
solution land best — NEXUS has a strong bias toward the elegant minimum, and the framework has
more than once solved a proposed feature by deleting something instead.

---

## Changing the framework

NEXUS is markdown. A change is almost always an edit to a harness section, a skill file, or a
template — not code.

**Where things live**, all relative to `plugins/nexus/project-template/`:

| You want to change | Edit |
|---|---|
| An always-on rule, protocol or preference | `CLAUDE.md` |
| How one operation behaves | `.claude/skills/nexus-{name}/SKILL.md` |
| A phase methodology | `.claude/skills/nexus-{analyze,build,validate,research,maintain}/` |
| What a new issue, pattern or state file looks like | `.nexus/templates/` |
| A guide | `.nexus/human-guides/` |
| Token tracking, YAML validation, backups | `.claude/hooks/` |

Two conventions worth matching, because a change that ignores them will be asked to change:

- **Version headers.** Framework files carry `*Version: X.Y.Z | Date: … | Sprint: …*` under the
  title. Bump it: major for structural section changes, minor for new or changed rules, patch for
  wording.
- **Features without access do not exist.** A new operation needs its routing entry in `CLAUDE.md`
  and its menu entry, not just a skill file.

---

## Testing a change

**Test it on a real installation, not on the repository.** The two are not the same tree, and
several defects have only ever appeared on the installed side.

1. Install NEXUS into an empty folder by either route in the
   [Installation Guide](plugins/nexus/project-template/.nexus/human-guides/installation-guide.md).
2. Apply your change to that installation.
3. Run `start` and complete a first boot: `/nexus-init-project` → `/nexus-setup-project` →
   `/nexus-generate-mvp` → `/nexus-organize-sprint`.
4. Exercise the operation you changed, and one that consumes it.
5. Record what the startup header said — including any `⚠` line. A change that adds a warning to
   a first boot is a regression even if the operation itself works.

The pull request template asks for the output of that run. It is the single most useful thing you
can attach.

---

## Pull requests

- One change per pull request. A branch that fixes a bug and rewrites a guide will be split.
- Say what you ran, on which route, and what the first boot printed.
- Expect a conversation rather than a merge button. Review is a genuine read, and the port
  upstream happens once the change is agreed.

Thank you for taking the time.
