# NEXUS Architecture — Visual Quick Guide
*Version: 2.0.2 | Date: 2026-08-25 | Sprint: 110*

**Source files**:
- `CLAUDE.md` v5.16.0 (System Nature, Routing Map, Phase-Management-Protocol)
- `.claude/skills/nexus-start/SKILL.md` v2.9.2 (boot sequence)
- `.nexus/active/NEXUS-Architecture.md` v4.1.0 (system relationship map)
- `.nexus/human-guides/nexus-framework-guide.md` v2.3.1 (the prose these diagrams illustrate)

> **Purpose**: see the shape of NEXUS in four diagrams (~5 minutes). This guide *shows*;
> [nexus-framework-guide.md](nexus-framework-guide.md) *explains*. For the architecture, the context
> zones, and the Control Levels consent model in prose, read
> [The Three Unbreakable Principles](nexus-framework-guide.md#the-three-unbreakable-principles) and
> [System Architecture](nexus-framework-guide.md#system-architecture) — this guide does not restate them.

---

## 1. The Shape of the System

NEXUS has three moving parts: a **harness** that is always loaded, **skills** that load on demand, and
**data** that everything reads and writes. Work flows through a fixed chain — Project → Sprints → Issues
(analyze → implement → evaluate) → Patterns → Evolution.

```mermaid
mindmap
  root((NEXUS))
    Harness
      CLAUDE.md
        Core Principles
        Control Levels
        Context Zones
        Routing Map
        Behavioral Preferences
    Skills
      Methodology - 5
        nexus-analyze
        nexus-research
        nexus-build
        nexus-validate
        nexus-maintain
      Cognitive - 3 packs
      Brainstorm - parallel phase
      Operations - 45
    Data
      states - 4 files
      registries - 4 YAML
      issues
      patterns
      seeds
      memory - 7 JSONL
      templates
      archived
```

**Counts verified on disk**: 54 skill folders under `.claude/skills/nexus-*/`, 4 state files, 4 registries,
7 memory files, 52 active patterns. `/nexus-build` additionally carries a **batch sub-mode** for repetitive
targets — it is a mode of Build, not a sixth methodology.

---

## 2. How the Layers Interact

Commands enter through the routing map in `CLAUDE.md`, skills do the work, and everything durable lands in
`.nexus/`. Nothing is hidden: each box below is a file or a folder you can open in a text editor.

```mermaid
flowchart LR
    subgraph User["You"]
        CMD["Commands<br/>natural language"]
    end

    subgraph Entry["Entry — the harness"]
        RT["CLAUDE.md<br/>Routing Map"]
        ST["/nexus-start"]
        MN["/nexus-menu"]
    end

    subgraph Work["Operation skills"]
        direction TB
        PRJ["Project ops"]
        SPR["Sprint ops"]
        ISS["Issue ops"]
        PAT["Pattern ops"]
    end

    subgraph Support["Support skills"]
        direction TB
        DOC["Documentation ops"]
        MNT["Maintenance ops"]
    end

    subgraph Meth["Methodology skills"]
        AN["/nexus-analyze"]
        RE["/nexus-research"]
        BU["/nexus-build<br/>+ batch sub-mode"]
        VA["/nexus-validate"]
        MA["/nexus-maintain"]
    end

    subgraph Persist[".nexus/ — the data"]
        direction TB
        SS[("sprint-state")]
        PS[("project-state")]
        SY[("system-state")]
        SQ[("sprint-queue")]
        IR[("issues-registry")]
        PR[("patterns-registry")]
        CR[("changelog-registry")]
        DR[("documentation-registry")]
        MEM[/"memory/ — 7 JSONL"/]
        IF[/"issues/ + patterns/"/]
        SF[/"Sprints/ archives"/]
    end

    CMD --> RT
    CMD --> MN
    RT --> ST
    RT --> Work
    RT --> Support
    MN --> Work
    MN --> Support
    ST --> SS
    ST --> Meth

    Meth -.->|guide the phase| Work
    PRJ --> PS
    SPR --> SS
    SPR --> SQ
    SPR --> SF
    SPR --> MEM
    ISS --> SS
    ISS --> IR
    ISS --> IF
    PAT --> PR
    MNT --> SY
    MNT --> CR
    DOC -.->|reads| DR
```

**The two files everything depends on**: `sprint-state.md` is the continuity lifeline — loaded every
conversation, and the reason a new conversation can pick up exactly where the last one stopped.
`issues-registry.yaml` is the single source of truth for issue phase scores.

**Two-place update rule**: an issue's phase scores are written to **both** `issues-registry.yaml` (source of
truth) and `sprint-state.md` `[OBJECTIVES]`. Updating only one is a protocol violation.

---

## 3. The Issue Lifecycle

Every piece of work follows the same path. Each phase has a methodology skill that guides it, and a phase
transition happens when that phase's score reaches ≥ 4/5 **and you approve it**. Research-type issues follow
A → R → E instead of A → I → E.

```mermaid
stateDiagram-v2
    [*] --> Planned: /nexus-create-issue
    Planned --> Analysis: /nexus-work-issue

    state Analysis {
        [*] --> Framing
        Framing --> Designing
        Designing --> PlanApproved: A >= 4
    }

    Analysis --> Implementation: standard issues
    Analysis --> Research: Research-type issues

    state Research {
        [*] --> Scoping
        Scoping --> Surveying
        Surveying --> Investigating
        Investigating --> Synthesizing
        Synthesizing --> Delivered: I >= 4
    }

    state Implementation {
        [*] --> Building
        Building --> Testing
        Testing --> Built: I >= 4
        state BatchMode {
            [*] --> TargetLoop
            TargetLoop --> Conformance
            Conformance --> TargetDone
        }
        Building --> BatchMode: repetitive targets
        BatchMode --> Building: fallback
    }

    Implementation --> Evaluation: I >= 4
    Research --> Evaluation: I >= 4

    state Evaluation {
        [*] --> Validating
        Validating --> Extracting: tests pass
        Extracting --> Evaluated: E >= 4
    }

    Evaluation --> Closed: /nexus-close-issue
    Closed --> Archived: /nexus-archive-issue
    Archived --> [*]

    Implementation --> Analysis: /nexus-loop-back
    Evaluation --> Implementation: /nexus-loop-back
    Evaluation --> Analysis: /nexus-loop-back
```

**Phase → skill**: Analysis → `/nexus-analyze` · Research → `/nexus-research` · Implementation →
`/nexus-build` (batch sub-mode included) · Evaluation → `/nexus-validate`. `/nexus-brainstorm` sits
**outside** this lifecycle as a parallel phase — you can enter it from any phase and exit to any phase.

**Sprints** wrap issues in three kinds of conversation: **Planning** (`/nexus-organize-sprint` creates the
sprint and selects issues), **Work** (issues move through their phases), and **Learning**
(`/nexus-close-sprint` extracts patterns, indexes the memory layer, updates project state).

---

## 4. The Boot Sequence

Every conversation starts here. You type "start"; `/nexus-start` detects where you left off, asks you to
confirm the phase and the session's Control Level, then loads exactly what that phase needs.

```mermaid
flowchart TD
    A["You type 'start'"] --> B["STEP 1-2: detect model window,<br/>write .context-window, check compaction"]
    B --> C["STEP 3: load sprint-state.md"]
    C --> D["STEP 4: freshness check on derived artifacts"]
    D --> LC{"_project_lifecycle?"}

    LC -->|not-defined| LC1(["DELEGATE /nexus-init-project"])
    LC -->|defining| LC2(["DELEGATE /nexus-setup-project"])
    LC -->|active or closed| SW{"_status?"}

    SW -->|ready| E1["Conv = 1"]
    SW -->|in_progress| E2["Conv = saved + 1"]
    SW -->|closing| E6["Learning phase"]
    SW -->|complete, properly closed| E3["Planning phase"]
    SW -->|complete, not closed| E5["Forced closure"]

    E1 --> F["STEP 7: detect work phase"]
    E2 --> F
    F --> G["STEP 8: assess complexity, load active ISS"]
    G --> H["STEP 9: widget —<br/>confirm phase + Control Level"]
    H --> I["Load the methodology skill"]
    I --> J["STEP 10: load files_to_load"]
    J --> K["STEP 11: startup header"]
    K --> L(["Ready — work phase"])

    E3 --> M["/nexus-organize-sprint"]
    E6 --> N["/nexus-close-sprint"]
    E5 --> E6
    M --> K
    N --> K
```

The widget at STEP 9 is the safety net: if the detected phase is wrong, you override it there, and nothing
loads until you have answered. Control Level is asked every conversation and is **not** remembered from the
last one.

---

## 5. Where to Go Deeper

| Resource | What You'll Find | Location |
|----------|-----------------|----------|
| **[NEXUS Framework Guide](nexus-framework-guide.md)** | The complete prose reference — principles, Control Levels, context zones, architecture, methodologies, cognitive tools, health system | `.nexus/human-guides/nexus-framework-guide.md` |
| **NEXUS-Architecture.md** | The full system relationship map — every skill, every file it reads and writes | `.nexus/active/NEXUS-Architecture.md` |
| **CLAUDE.md** | The harness itself — protocols, routing map, preferences, principles. Readable end to end | `CLAUDE.md` |
| **The skills** | What each operation actually does, step by step | `.claude/skills/nexus-*/SKILL.md` |
