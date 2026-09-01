# Data & Analytics
*Domain Profile v1.0.0 | Sprint: 060*

[Section: Profile]
type_name: "Data & Analytics"
category: "Technical"
description: "Building data pipelines, analytical models, dashboards, or data-driven insights. Choose when the primary work is acquiring, transforming, modeling, or visualizing data."
wizard_emphasis: "Data quality, methodology rigor, reproducibility, pipeline reliability, insight actionability"
phase_character: "Acquire-explore-model-validate — iterative with data quality gates. May pivot when data reveals unexpected patterns or limitations."
typical_deliverables: "Pipelines, models, dashboards, reports, datasets, analytical frameworks"
wizard_depth: "standard"

spec_version: "1.0.0"
template_version: "1.0.0"
[/Section: Profile]

[Section: Framing-Hints]
vision_question: "What decisions or insights should the data enable? What question are we answering with data?"
scope_emphasis: "Data boundaries — which sources, what time range, what granularity, what's excluded and why"
deliverable_framing: "Actionable outputs — dashboards people use, models that inform decisions, pipelines that run reliably"
risk_framing: "Data quality issues, bias in data or models, reproducibility failures, pipeline fragility"
effort_framing: "Sprints map to data cycles — acquire, explore, model, validate. Data exploration may take longer than expected."
constraint_emphasis: "Data availability, access permissions, privacy requirements, computational resources, freshness requirements"
[/Section: Framing-Hints]

[Section: Deliverable-Templates]
### MVP Examples
- name: "Data Pipeline"
  description: "Automated data acquisition, transformation, and loading from source to target"
  quality_criteria: "Runs reliably on schedule, handles errors gracefully, data freshness meets requirements"
- name: "Analytical Model / Analysis"
  description: "Statistical model, ML model, or structured analysis that answers the core question"
  quality_criteria: "Methodology documented, results reproducible, accuracy meets defined threshold"
- name: "Dashboard / Reporting"
  description: "Visual interface for monitoring key metrics and exploring data"
  quality_criteria: "Answers primary questions without explanation, updates automatically, loads within acceptable time"

### Enhanced Examples
- name: "Data Quality Framework"
  description: "Automated checks for completeness, consistency, freshness, and anomaly detection"
  quality_criteria: "Catches known data issues automatically, alerts on anomalies, tracks quality trends"
- name: "Advanced Analytics"
  description: "Predictive models, segmentation, trend analysis, or scenario modeling"
  quality_criteria: "Model performance validated on holdout data, limitations documented, retraining plan defined"
- name: "Self-Service Analytics"
  description: "Tools and documentation enabling non-technical users to explore data independently"
  quality_criteria: "Users can answer common questions without analyst support"

### Future Examples
- name: "Real-Time Analytics"
  description: "Streaming data processing with live dashboards and automated triggers"
  quality_criteria: "Sub-minute latency, handles data volume spikes, triggers fire reliably"
- name: "Data Platform"
  description: "Shared infrastructure for data storage, processing, and access across teams"
  quality_criteria: "Multiple consumers served, governance in place, scalable to growing needs"

### Categorization Guidance
"MVP = the core question is answerable with reliable data. Enhanced = the answer is automated, validated, and accessible. Future = the data capability serves the broader organization."
[/Section: Deliverable-Templates]

[Section: Phase-Templates]
### Simple (2-3 phases)
- phase: "Data Assessment & Pipeline"
  objective: "Assess data sources, build acquisition and transformation pipeline, validate data quality"
  typical_deliverables: "Data pipeline, source documentation, quality assessment"
  milestone: "Clean, reliable data flowing to target destination"
- phase: "Analysis & Delivery"
  objective: "Build analytical model or dashboard, validate results, deploy"
  typical_deliverables: "Model or dashboard, validation results, documentation"
  milestone: "Analytical output live and answering the core question"

### Standard (3-4 phases)
- phase: "Data Discovery"
  objective: "Assess data sources, understand quality and availability, define data architecture"
  typical_deliverables: "Data source inventory, quality assessment, architecture design"
  milestone: "Data landscape understood, viable path to answering core question confirmed"
- phase: "Pipeline Development"
  objective: "Build data acquisition, transformation, and loading infrastructure"
  typical_deliverables: "Working pipeline, data validation checks, schema documentation"
  milestone: "Data flowing reliably with quality checks passing"
- phase: "Modeling & Analysis"
  objective: "Build analytical models, explore data, generate insights"
  typical_deliverables: "Analytical model, exploratory analysis, initial findings"
  milestone: "Model performs above accuracy threshold on validation data"
- phase: "Validation & Deployment"
  objective: "Validate results, build dashboards, deploy to production, document methodology"
  typical_deliverables: "Dashboard, validation report, methodology documentation, monitoring"
  milestone: "Analytics live in production with monitoring and documentation"

### Complex (5-6 phases)
- phase: "Problem Framing & Data Audit"
  objective: "Define analytical questions precisely, inventory all data sources, assess feasibility"
  typical_deliverables: "Analytical brief, data source audit, feasibility assessment"
  milestone: "Questions formalized, data availability confirmed, approach selected"
- phase: "Data Engineering"
  objective: "Build robust pipeline infrastructure: ingestion, transformation, storage, quality gates"
  typical_deliverables: "Data pipeline, quality framework, schema documentation"
  milestone: "Pipeline handles full data volume with quality checks passing"
- phase: "Exploratory Analysis"
  objective: "Understand data patterns, test assumptions, identify features and anomalies"
  typical_deliverables: "Exploratory analysis report, feature engineering, hypothesis validation"
  milestone: "Key patterns understood, features identified for modeling"
- phase: "Model Development"
  objective: "Build, train, and tune analytical models with rigorous validation"
  typical_deliverables: "Trained models, performance benchmarks, methodology documentation"
  milestone: "Model meets accuracy and fairness thresholds on holdout data"
- phase: "Visualization & Integration"
  objective: "Build dashboards, integrate models into workflows, create self-service access"
  typical_deliverables: "Dashboards, API endpoints, self-service documentation"
  milestone: "Stakeholders can access insights through intended channels"
- phase: "Production & Monitoring"
  objective: "Deploy to production, establish monitoring, define retraining and maintenance plan"
  typical_deliverables: "Production deployment, monitoring dashboards, maintenance runbook"
  milestone: "Analytics running reliably in production with drift detection"

### Phase Naming Guidance
"Use data lifecycle language: Discovery, Engineering, Exploration, Modeling, Validation, Deployment. Avoid generic software terms (Foundation, Hardening) unless building a data platform."
[/Section: Phase-Templates]

[Section: Risk-Catalog]
- risk: "Data quality worse than expected — missing values, inconsistencies, stale data"
  probability: "High"
  impact: "High"
  mitigation_hint: "Profile data quality early in discovery, define minimum viable data quality, have fallback data sources"
- risk: "Bias in data leading to biased models or misleading insights"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Audit data for representation issues, test model fairness explicitly, document known biases"
- risk: "Reproducibility failure — results can't be recreated with the same inputs"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Version data and code together, document random seeds and environment, automate the full pipeline"
- risk: "Pipeline fragility — works in development, breaks with production data volumes or edge cases"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Test with production-scale data early, handle schema changes gracefully, build monitoring from day one"
- risk: "Analysis doesn't answer the business question (technically correct but not actionable)"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Validate analytical questions with stakeholders before building, show intermediate results early"
- risk: "Model drift — accuracy degrades over time as underlying patterns change"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Define monitoring for model performance, plan retraining schedule, set alerting thresholds"
[/Section: Risk-Catalog]

[Section: Metrics]
quantitative:
  - "Model accuracy or performance metric (domain-appropriate: RMSE, F1, AUC, etc.)"
  - "Pipeline reliability (successful runs vs total, data freshness vs SLA)"
  - "Data coverage (records processed vs available, completeness rate)"
qualitative:
  - "Insight actionability (do stakeholders change decisions based on this?)"
  - "Methodology rigor (reproducible, documented, defensible)"
  - "Dashboard usability (do users find answers without training?)"
milestone_examples:
  - "Data sources assessed and pipeline architecture designed"
  - "Pipeline running reliably with quality checks"
  - "Model meets accuracy threshold on validation data"
  - "Dashboard live with stakeholder sign-off"
[/Section: Metrics]

[Section: Issue-Breakdown]
breakdown_pattern: "pipeline-oriented"
pattern_description: "Issues follow the data lifecycle: acquire, transform, model, visualize, monitor. Each issue covers a specific data flow or analytical component."
typical_structure:
  - type: "Data Source Integration"
    description: "Connect to a specific data source, handle extraction and initial quality checks"
    typical_complexity: "2-3"
  - type: "Data Transformation"
    description: "Build transformation logic for a specific data domain or use case"
    typical_complexity: "3"
  - type: "Analytical Model"
    description: "Develop, train, and validate a specific model or analysis"
    typical_complexity: "3-4"
  - type: "Visualization / Dashboard"
    description: "Build a specific dashboard view or reporting component"
    typical_complexity: "2-3"
  - type: "Data Quality & Monitoring"
    description: "Implement quality checks, monitoring, and alerting for a data domain"
    typical_complexity: "2-3"
example_titles:
  - "Ingest and profile customer transaction data from payment API"
  - "Build feature engineering pipeline for churn prediction model"
  - "Develop and validate customer segmentation model"
  - "Create executive KPI dashboard with drill-down capability"
  - "Implement data quality monitoring for sales pipeline data"

### Cross-Cutting Patterns
"Data governance (naming conventions, access control, documentation standards) and environment management (dev/staging/production parity) span all data work — establish these early."
[/Section: Issue-Breakdown]
