# Research & Analysis
*Domain Profile v1.0.0 | Sprint: 060*

[Section: Profile]
type_name: "Research & Analysis"
category: "Research"
description: "Investigating questions, producing evidence-based findings and recommendations. Choose when the primary output is knowledge, not a built artifact."
wizard_emphasis: "Methodological rigor, evidence quality, research questions, reproducibility"
phase_character: "Exploration-heavy — may pivot based on findings, phases follow methodology stages"
typical_deliverables: "Findings, recommendations, reports, datasets, frameworks, decision models"
wizard_depth: "standard"

spec_version: "1.0.0"
template_version: "1.0.0"
[/Section: Profile]

[Section: Framing-Hints]
vision_question: "What question are we trying to answer, and why does it matter?"
scope_emphasis: "Research boundaries — what's in scope to investigate vs what we take as given"
deliverable_framing: "Findings and recommendations, not features — what will the audience learn or decide?"
risk_framing: "Inconclusive results, methodology limitations, data access, confirmation bias"
effort_framing: "Sprints map to research stages, not build cycles — analysis phases may run longer"
constraint_emphasis: "Data availability, methodological requirements, ethical considerations, reproducibility standards"
[/Section: Framing-Hints]

[Section: Deliverable-Templates]
### MVP Examples
- name: "Research Report / Findings Document"
  description: "Core findings with evidence, analysis, and actionable recommendations"
  quality_criteria: "Claims supported by evidence, methodology documented, conclusions follow from data"
- name: "Methodology Framework"
  description: "Documented approach: research questions, methods, data sources, analysis techniques"
  quality_criteria: "Reproducible by another researcher following the same steps"
- name: "Data Collection & Analysis"
  description: "Gathered data, cleaned datasets, analysis results with statistical or qualitative rigor"
  quality_criteria: "Data provenance documented, analysis steps traceable, results reproducible"

### Enhanced Examples
- name: "Literature Review / State of the Art"
  description: "Systematic survey of existing knowledge, gaps identified, positioning of new contribution"
  quality_criteria: "Comprehensive coverage of relevant sources, synthesis not just summary"
- name: "Decision Framework"
  description: "Structured model for making decisions based on research findings"
  quality_criteria: "Inputs, criteria, and trade-offs clearly defined; usable by decision-makers"
- name: "Validation Study"
  description: "Independent validation of findings through replication, cross-checking, or expert review"
  quality_criteria: "Findings confirmed or limitations clearly documented"

### Future Examples
- name: "Publication / External Communication"
  description: "Paper, article, or presentation for external audience"
  quality_criteria: "Peer-review ready or audience-appropriate communication standard"
- name: "Follow-Up Research Agenda"
  description: "Identified questions and directions for future investigation"
  quality_criteria: "Grounded in current findings, prioritized by impact and feasibility"

### Categorization Guidance
"MVP = the core question is answered with evidence. Enhanced = the answer is robust, validated, and contextualized. Future = findings reach broader audiences or seed new investigations."
[/Section: Deliverable-Templates]

[Section: Phase-Templates]
### Simple (2-3 phases)
- phase: "Investigation"
  objective: "Define questions, gather data, conduct analysis"
  typical_deliverables: "Methodology framework, data collection, initial findings"
  milestone: "Research questions answered with supporting evidence"
- phase: "Synthesis & Reporting"
  objective: "Consolidate findings, write recommendations, document methodology"
  typical_deliverables: "Research report, recommendations, documented methodology"
  milestone: "Final report delivered with actionable recommendations"

### Standard (3-4 phases)
- phase: "Scoping & Literature Review"
  objective: "Define research questions, survey existing knowledge, identify gaps"
  typical_deliverables: "Literature review, refined research questions, methodology design"
  milestone: "Research questions validated against existing knowledge"
- phase: "Data Collection & Analysis"
  objective: "Gather evidence through chosen methodology, analyze systematically"
  typical_deliverables: "Datasets, analysis results, emerging findings"
  milestone: "Sufficient evidence collected to address research questions"
- phase: "Synthesis & Recommendations"
  objective: "Consolidate findings, derive conclusions, formulate recommendations"
  typical_deliverables: "Research report, decision framework, recommendations"
  milestone: "Findings synthesized into actionable output"
- phase: "Validation & Communication"
  objective: "Verify findings, prepare for audience, incorporate feedback"
  typical_deliverables: "Validated report, presentation, follow-up agenda"
  milestone: "Findings validated and communicated to stakeholders"

### Complex (5-6 phases)
- phase: "Problem Framing"
  objective: "Understand the landscape, define precise research questions, identify assumptions"
  typical_deliverables: "Research brief, assumption inventory, stakeholder map"
  milestone: "Research questions agreed and methodology approach selected"
- phase: "Literature Review & Gap Analysis"
  objective: "Systematic survey of existing knowledge, position contribution"
  typical_deliverables: "Literature review, gap analysis, refined hypotheses"
  milestone: "Knowledge gaps confirmed, hypotheses formulated"
- phase: "Methodology Design & Pilot"
  objective: "Design research approach, pilot on subset, refine methods"
  typical_deliverables: "Methodology framework, pilot results, refined approach"
  milestone: "Methodology validated through pilot"
- phase: "Full Data Collection & Analysis"
  objective: "Execute research at full scale, rigorous analysis"
  typical_deliverables: "Complete datasets, statistical/qualitative analysis, raw findings"
  milestone: "All data collected and analyzed"
- phase: "Synthesis & Validation"
  objective: "Integrate findings, cross-validate, derive conclusions"
  typical_deliverables: "Integrated findings, decision models, validated conclusions"
  milestone: "Findings withstand scrutiny and cross-validation"
- phase: "Reporting & Dissemination"
  objective: "Write final deliverables, present to stakeholders, define follow-up"
  typical_deliverables: "Final report, presentations, publication drafts, follow-up agenda"
  milestone: "Research delivered and accepted by audience"

### Phase Naming Guidance
"Use research methodology stages: Scoping, Literature Review, Data Collection, Analysis, Synthesis, Validation, Dissemination. Avoid software terms (Foundation, Implementation, Hardening)."
[/Section: Phase-Templates]

[Section: Risk-Catalog]
- risk: "Research question too broad or too vague to answer conclusively"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Refine questions iteratively during scoping, define 'answerable' criteria upfront"
- risk: "Data unavailable, insufficient, or lower quality than expected"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Identify data sources early, have backup sources, define minimum viable dataset"
- risk: "Methodology limitations invalidate findings"
  probability: "Low"
  impact: "High"
  mitigation_hint: "Pilot methodology on subset before full execution, document limitations explicitly"
- risk: "Confirmation bias — finding what you expect rather than what's there"
  probability: "High"
  impact: "Medium"
  mitigation_hint: "Pre-register hypotheses, seek disconfirming evidence, use blind analysis where possible"
- risk: "Inconclusive results after significant effort"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Define early decision points — if data shows X by phase N, pivot approach"
- risk: "Scope creep through expanding research questions"
  probability: "High"
  impact: "Medium"
  mitigation_hint: "Lock core questions after scoping, capture new questions for follow-up agenda"
[/Section: Risk-Catalog]

[Section: Metrics]
quantitative:
  - "Research questions answered with supporting evidence"
  - "Sources reviewed and synthesized"
  - "Data completeness (coverage of intended scope)"
qualitative:
  - "Rigor of methodology (reproducible, documented, defensible)"
  - "Quality of synthesis (insights beyond data summary)"
  - "Actionability of recommendations (specific enough to act on)"
milestone_examples:
  - "Research questions validated and methodology approved"
  - "Literature review complete with gap analysis"
  - "Data collection finished with quality assessment"
  - "Final report accepted by stakeholders"
[/Section: Metrics]

[Section: Issue-Breakdown]
breakdown_pattern: "methodology-oriented"
pattern_description: "Issues follow research methodology stages. Each issue covers a distinct stage that produces a verifiable output — not a task within a stage."
typical_structure:
  - type: "Literature Review"
    description: "Survey existing knowledge on a specific topic or question"
    typical_complexity: "3"
  - type: "Methodology Design"
    description: "Define research approach, tools, data collection strategy"
    typical_complexity: "3-4"
  - type: "Data Collection"
    description: "Gather evidence through defined methodology"
    typical_complexity: "2-3"
  - type: "Analysis & Synthesis"
    description: "Process data, identify patterns, derive findings"
    typical_complexity: "3-4"
  - type: "Report & Communication"
    description: "Write findings, create presentations, prepare deliverables"
    typical_complexity: "2-3"
example_titles:
  - "Literature review on distributed consensus mechanisms"
  - "Design mixed-methods research framework for user behavior study"
  - "Collect and clean survey data from target population"
  - "Analyze interview transcripts and synthesize themes"
  - "Write findings report with recommendations for stakeholders"

### Cross-Cutting Patterns
"Research ethics review and data management planning often span all stages — consider establishing these as foundational issues before investigation begins."
[/Section: Issue-Breakdown]
