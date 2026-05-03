---
name: autobus-prolog
description: Use when generating and executing SWI-Prolog logic for the autobus-paper neuro-symbolic architecture. Trigger this when asked to perform business tasks (e.g., Task 1, 2, 3) that require translating natural language requirements into formal logic and executing them against the SQLite database.
---

# Autobus Prolog

## Overview
This skill enables Gemini CLI to act as the core reasoning engine for the Autobus project. It uses a multi-agent validation loop to ensure that generated Prolog code is correct, syntactically valid, and adheres to business requirements before execution.

## Workflow

### 1. Initialization & Context Gathering
- **Action**: Establish a versioned directory for the current run: `generated/runs/<task_id>/v<N>/`.

### 2. Logic Generation (The Generator)
- **Agent**: Spawn a sub-agent to translate the natural language task into Prolog.
- **Action**: 
    - Run `python autobus-prolog/scripts/get_db_schema.py` to get the database schema.
    - Read `autobus-prolog/references/prolog_template.pl` to load foundational Prolog rules and database connection logic.
    - Read `tasks/<task_id>.md` for the specific requirements.
- **Goal**: Create a Janus-SWI compliant Prolog file.
- **Output**: Save to `generated/runs/<task_id>/v<N>/candidate.pl`.

### 3. Syntax Check
- **Action**: Run the syntax check: `python autobus-prolog/scripts/validate_syntax.py generated/runs/<task_id>/v<N>/candidate.pl`.
- **Goal**: Ensure the Prolog code is syntactically correct and adheres to Janus-SWI conventions.
- **If Failed**: Provide feedback to the Generator and restart Step 2 with an incremented version `v<N+1>`.

### 4. Multi-Agent Validation Loop (The Evaluators)
- **Agent**: Spawn three independent sub-agents (using different backend models where possible). 
    - **Evaluator A (Business Logic)**: Verifies if the logic strictly follows all criteria in the Task instruction.
    - **Evaluator B (Syntax & Schema)**: Verifies if table/column names match the schema and if Janus-SWI predicates are used correctly.
    - **Evaluator C (Edge Cases & Safety)**: Checks for SQL safety, handling of nulls/missing data, and logical edge cases.
- **Action**: Each evaluator reads the `candidate.pl` and the original task instructions.
- **Goal**: Evaluate the `candidate.pl` against the original task instructions on the three dimensions (business logic, syntax/schema, edge cases)
- **Output**: Each evaluator writes their findings to `generated/runs/<task_id>/v<N>/eval_<A|B|C>_report.md`.

### 5. Consensus Review (The Reviewer)
- **Agent**: Spawn a sub-agent to review the three evaluation reports.
- **Action**: Read three evaluation reports, synthesize findings, identify contradictions (split decisions), and produce a final recommendation.
- **Output**: Save to `generated/runs/<task_id>/v<N>/review_summary.md`.

### 6. Human Approval & Feedback
- **Action**: Present the `review_summary.md` and `candidate.pl` to the user.
- **Decision**:
    - **Approved**: Copy `candidate.pl` to `generated/<task_id>_logic.pl` and execute.
    - **Feedback**: If the user provides feedback or updates instructions, the Lead Agent merges the new info with the initial task and restarts from Step 2 (incrementing the version `v<N+1>`).

### 7. Execution
- **Action**: Run the program:
  ```bash
  uv run --script autobus-prolog/scripts/run_prolog.py generated/<task_id>_logic.pl
  ```

## State Management
Always maintain the `generated/runs/` history. Do not delete old versions. Use these files to explain the reasoning process if the user asks.
