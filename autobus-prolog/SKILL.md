---
name: autobus-prolog
description: Use when generating and executing SWI-Prolog logic for the autobus-paper neuro-symbolic architecture. Trigger this when asked to perform business tasks (e.g., Task 1, 2, 3) that require translating natural language requirements into formal logic and executing them against the SQLite database.
---

# Autobus Prolog

## Overview
This skill enables Gemini CLI to act as the core reasoning engine for the Autobus project. It provides a structured workflow to translate natural language business requirements into precise SWI-Prolog code, which is then executed against the project's SQLite database to perform deterministic data operations.

## Workflow

To execute a business task using this skill, follow these steps:

### 1. Gather Context
First, obtain the current database schema to ensure the generated Prolog logic matches the table structures and constraints.
- **Action**: Run `python autobus-prolog/scripts/get_db_schema.py`.
- **Reason**: The LLM needs to know exactly which tables and columns are available (e.g., `consumer`, `subscription`, `profile_attribute`).

### 2. Retrieve Template
Load the foundational Prolog rules and database connection logic.
- **Action**: Read `autobus-prolog/references/prolog_template.pl`.
- **Reason**: This provides the standard `init_db`, `main`, and helper predicates required for Janus-SWI execution.

### 3. Generate Logic
Translate the user's business requirements into task-specific Prolog rules.
- **Guidelines**:
    - Identify the **Task ID** from the request (e.g., `task_1`, `task_2`).
    - Define the core business logic as Prolog predicates.
    - Implement the `save_outcome_to_database` predicate to perform the final data transformation or tool calls.
    - Use the `py_call` mechanism if external tools (like web search or marketing APIs) are required.

### 4. Save and Execute
- **Save**: Write the complete Prolog program to `generated/<Task ID>_logic.pl`.
- **Execute**: Run the program using the project's execution bridge:
  ```bash
  uv run --script autobus-prolog/scripts/run_prolog.py generated/<Task ID>_logic.pl
  ```

## Example Task
If a user asks: *"Run Task 1: Identify savable churners with high risk and subscription rate >= 10"*:
1. Run `get_db_schema.py`.
2. Read `prolog_template.pl`.
3. Generate logic that filters `subscription` joined with `profile_attribute` (for churn indicators).
4. Save to `generated/task_1_logic.pl`.
5. Execute via `run_prolog.py`.
