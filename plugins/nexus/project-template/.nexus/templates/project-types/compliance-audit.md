# Compliance / Audit
*Domain Profile v1.0.0 | Sprint: 060*

[Section: Profile]
type_name: "Compliance / Audit"
category: "Business"
description: "Achieving regulatory compliance, conducting audits, or implementing governance frameworks. Choose when the work is driven by external requirements, standards, or regulations that must be met and demonstrated."
wizard_emphasis: "Requirement traceability, evidence documentation, gap analysis rigor, remediation tracking, audit readiness"
phase_character: "Scope-assess-remediate-document-certify — systematic and evidence-driven. Every claim must be traceable to evidence. No shortcuts, no assumptions."
typical_deliverables: "Gap analyses, remediation plans, compliance evidence packages, audit reports, policy documents, certification submissions"
wizard_depth: "thorough"

spec_version: "1.0.0"
template_version: "1.0.0"
[/Section: Profile]

[Section: Framing-Hints]
vision_question: "What standard, regulation, or governance goal must we meet, and what does compliant look like in concrete terms?"
scope_emphasis: "Compliance boundaries — which requirements, which systems or processes, which organizational units, what's excluded"
deliverable_framing: "Evidence-backed compliance artifacts — every deliverable must demonstrate compliance, not just describe intent"
risk_framing: "Incomplete scope, evidence gaps, remediation delays, changing requirements, false sense of compliance"
effort_framing: "Sprints map to compliance domains — assess, remediate, document, verify. Evidence collection often takes longer than expected."
constraint_emphasis: "Regulatory deadlines, audit schedules, evidence format requirements, third-party assessment windows"
[/Section: Framing-Hints]

[Section: Deliverable-Templates]
### MVP Examples
- name: "Requirement Mapping & Gap Analysis"
  description: "Complete mapping of requirements to current state, with gaps identified and severity-rated"
  quality_criteria: "Every requirement addressed, gaps evidence-based not assumed, severity reflects actual risk"
- name: "Remediation Plan"
  description: "Prioritized plan to close identified gaps with owners, timelines, and evidence requirements"
  quality_criteria: "Each gap has a remediation action, owner, deadline, and defined evidence of completion"
- name: "Compliance Evidence Package"
  description: "Organized collection of evidence demonstrating compliance for each requirement"
  quality_criteria: "Evidence is current, traceable to specific requirements, sufficient for audit review"

### Enhanced Examples
- name: "Policy & Procedure Documentation"
  description: "Formal policies and procedures that implement compliance requirements"
  quality_criteria: "Policies cover all in-scope requirements, procedures are actionable, review and approval documented"
- name: "Internal Audit Report"
  description: "Independent assessment of compliance status with findings, evidence, and recommendations"
  quality_criteria: "Findings supported by evidence, recommendations prioritized, methodology documented"
- name: "Training & Awareness Program"
  description: "Training materials and records demonstrating staff awareness of compliance requirements"
  quality_criteria: "Content covers relevant requirements, completion tracked, comprehension assessed"

### Future Examples
- name: "Continuous Compliance Monitoring"
  description: "Automated or recurring checks that maintain compliance between audit cycles"
  quality_criteria: "Key controls monitored continuously, deviations flagged automatically, audit trail maintained"
- name: "Compliance Management Framework"
  description: "Organizational capability for managing compliance across multiple standards and regulations"
  quality_criteria: "New requirements can be integrated, evidence management centralized, audit readiness maintained"

### Categorization Guidance
"MVP = all requirements mapped, gaps identified, and critical gaps remediated with evidence. Enhanced = compliance is documented, auditable, and organizational awareness established. Future = compliance is sustained without project-mode effort."
[/Section: Deliverable-Templates]

[Section: Phase-Templates]
### Simple (2-3 phases)
- phase: "Assessment & Gap Analysis"
  objective: "Map requirements, assess current state, identify and prioritize gaps"
  typical_deliverables: "Requirement mapping, gap analysis, remediation priorities"
  milestone: "All gaps identified with severity ratings and remediation approach agreed"
- phase: "Remediation & Documentation"
  objective: "Close gaps, collect evidence, prepare compliance documentation"
  typical_deliverables: "Remediation evidence, compliance package, updated policies"
  milestone: "All critical gaps closed with traceable evidence"

### Standard (3-4 phases)
- phase: "Scoping & Requirement Mapping"
  objective: "Define compliance scope, map all requirements, understand current obligations"
  typical_deliverables: "Compliance scope definition, requirement register, stakeholder mapping"
  milestone: "Complete requirement set identified with organizational scope agreed"
- phase: "Assessment & Gap Analysis"
  objective: "Evaluate current state against each requirement, identify and categorize gaps"
  typical_deliverables: "Gap analysis report, current state evidence, risk-rated finding list"
  milestone: "All gaps identified, risk-rated, and prioritized for remediation"
- phase: "Remediation"
  objective: "Implement changes to close gaps, collect evidence, update policies and procedures"
  typical_deliverables: "Remediation actions, evidence collection, policy updates, procedure changes"
  milestone: "All critical and high-priority gaps remediated with evidence"
- phase: "Documentation & Audit Readiness"
  objective: "Assemble compliance package, conduct internal review, prepare for external audit"
  quality_criteria: "Evidence package complete, internal review passed, audit-ready"
  typical_deliverables: "Compliance evidence package, internal audit report, audit preparation materials"
  milestone: "Organization audit-ready with complete evidence package"

### Complex (5-6 phases)
- phase: "Scoping & Landscape Analysis"
  objective: "Map regulatory landscape, define organizational scope, identify all applicable requirements"
  typical_deliverables: "Regulatory landscape analysis, scope definition, requirement register"
  milestone: "All applicable requirements identified with organizational scope boundaries defined"
- phase: "Current State Assessment"
  objective: "Detailed assessment of current compliance posture across all requirement domains"
  typical_deliverables: "Current state inventory, control assessments, evidence of existing compliance"
  milestone: "Complete picture of current compliance with evidence for each domain"
- phase: "Gap Analysis & Remediation Planning"
  objective: "Identify all gaps, risk-rate findings, design remediation roadmap"
  typical_deliverables: "Gap analysis report, risk assessment, remediation plan with dependencies"
  milestone: "Prioritized remediation roadmap approved by stakeholders"
- phase: "Remediation Execution"
  objective: "Implement remediation actions systematically, collect evidence progressively"
  typical_deliverables: "Implemented controls, updated policies, evidence artifacts"
  milestone: "All critical and high-priority remediations complete with evidence"
- phase: "Internal Audit & Review"
  objective: "Independent internal review of compliance status, verify evidence completeness"
  typical_deliverables: "Internal audit report, evidence review findings, remaining gap list"
  milestone: "Internal audit confirms readiness (or identifies remaining items)"
- phase: "Certification & Sustainment"
  objective: "External audit or certification, establish ongoing monitoring, transition to BAU"
  typical_deliverables: "Certification submission, monitoring framework, compliance maintenance plan"
  milestone: "Certification achieved (or audit passed) with sustainment plan active"

### Phase Naming Guidance
"Use compliance lifecycle language: Scoping, Assessment, Gap Analysis, Remediation, Audit, Certification, Sustainment. Emphasize the evidence-driven and requirement-traceable nature of the work. Avoid software terms (Sprint, Deploy, Ship) and generic business terms (Strategy, Alignment)."
[/Section: Phase-Templates]

[Section: Risk-Catalog]
- risk: "Incomplete requirement scoping — discovering additional obligations mid-project"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Invest heavily in scoping phase, consult regulatory experts, review recent enforcement actions for scope clues"
- risk: "Evidence gaps — controls exist but evidence is insufficient for audit"
  probability: "High"
  impact: "High"
  mitigation_hint: "Define evidence requirements per control upfront, collect evidence as remediation happens not afterward"
- risk: "Remediation takes longer than planned due to organizational or technical complexity"
  probability: "High"
  impact: "Medium"
  mitigation_hint: "Start with highest-risk gaps, build buffer for complex remediations, escalate blockers early"
- risk: "Regulatory requirements change during the project"
  probability: "Low"
  impact: "High"
  mitigation_hint: "Monitor regulatory updates, design controls to be adaptable, build relationship with regulatory body"
- risk: "False sense of compliance — policies exist on paper but aren't followed in practice"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Test controls operationally not just documentarily, interview practitioners, spot-check evidence"
- risk: "Audit finding disputes — disagreement on interpretation of requirements"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Document interpretation rationale, seek pre-assessment guidance where possible, maintain evidence trail for judgement calls"
[/Section: Risk-Catalog]

[Section: Metrics]
quantitative:
  - "Requirements mapped and assessed (coverage rate)"
  - "Gaps identified vs remediated (closure rate)"
  - "Evidence artifacts collected vs required (completeness)"
  - "Audit findings by severity (critical/major/minor/observation)"
qualitative:
  - "Evidence quality (would this survive external audit scrutiny?)"
  - "Organizational awareness of compliance obligations"
  - "Sustainability of compliance posture (can this be maintained without project effort?)"
milestone_examples:
  - "All requirements mapped with organizational scope agreed"
  - "Gap analysis complete with risk-rated findings"
  - "Critical gaps remediated with evidence collected"
  - "Internal audit passed (or external certification achieved)"
[/Section: Metrics]

[Section: Issue-Breakdown]
breakdown_pattern: "requirement-domain-oriented"
pattern_description: "Issues follow compliance requirement domains or control families. Each issue covers a coherent set of related requirements that can be assessed, remediated, and evidenced together."
typical_structure:
  - type: "Requirement Mapping"
    description: "Map and analyze requirements for a specific domain or control family"
    typical_complexity: "2-3"
  - type: "Gap Assessment"
    description: "Assess current state against requirements for a specific domain"
    typical_complexity: "3"
  - type: "Remediation"
    description: "Implement controls and collect evidence for a specific requirement set"
    typical_complexity: "3-4"
  - type: "Policy Development"
    description: "Write or update formal policies and procedures for a compliance domain"
    typical_complexity: "2-3"
  - type: "Audit Preparation"
    description: "Assemble evidence package, conduct internal review for a specific domain"
    typical_complexity: "2"
example_titles:
  - "Map data protection requirements and identify applicable controls"
  - "Assess access management controls against security framework requirements"
  - "Implement and evidence encryption controls for data-at-rest"
  - "Develop incident response policy and procedure documentation"
  - "Prepare evidence package for annual security audit"

### Cross-Cutting Patterns
"Evidence management and requirement traceability span all compliance domains — establish the evidence repository structure and traceability matrix as a foundational issue before domain-specific assessment begins."
[/Section: Issue-Breakdown]
