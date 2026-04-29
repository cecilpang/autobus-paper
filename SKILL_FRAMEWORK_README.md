# Implementation Plan: Gemini CLI Skill for Neuro-symbolic AI

## Objective
Create a native Gemini CLI Skill (`autobus-prolog`) that allows the Gemini agent to act as the core reasoning engine for the `autobus-paper` project. This will replace the need for the external `openai-agents` library, allowing users to execute natural language business tasks directly through the Gemini CLI.

## Feasibility Justification
This idea is **highly feasible and architecturally elegant**.
Currently, `core_agent.py` acts as a middleman to an LLM, gathering the database schema and a Prolog template to generate `.pl` files. 
By creating a Gemini CLI Skill, we can transfer this exact procedural knowledge directly into Gemini CLI. 
*   **Context Management:** We can bundle the Prolog template as a `reference` file and use a lightweight `script` to fetch the DB schema on demand.
*   **Execution:** Gemini CLI natively supports executing terminal commands, meaning it can easily run `janus-swi` (via `src/run_prolog.py`) to execute the generated logic.
*   **Result:** A seamless workflow where you can type "Identify high risk churners" into Gemini CLI, and it will autonomously generate the Prolog logic and execute it against your SQLite DB.

## Skill Architecture (`autobus-prolog` skill)

The skill will be structured as follows:

```text
autobus-prolog/
├── SKILL.md                 # Core instructions on how to translate tasks to Prolog and execute them.
├── scripts/
│   └── get_db_schema.py     # Python script to dump the db.sqlite schema (extracted from core_agent.py)
└── references/
    └── prolog_template.md   # The contents of facts_tools_rules_actions.pl
```

### 1. `SKILL.md` (The "Brain")
*   **Description trigger:** "Use when generating and executing SWI-Prolog logic for the autobus-paper neuro-symbolic architecture."
*   **Workflow Instructions:**
    1.  Run `scripts/get_db_schema.py` to get the current database constraints.
    2.  Read `references/prolog_template.md`.
    3.  Generate the complete Prolog logic based on the user's task, replacing the template placeholders.
    4.  Save the file to `generated/<task_name>_logic.pl`.
    5.  Execute the script via `uv run --script src/run_prolog.py generated/<task_name>_logic.pl`.

### 2. `scripts/get_db_schema.py`
A lightweight script that connects to `database/db.sqlite` and prints the DDL statements. This allows Gemini CLI to fetch the live schema without relying on the old `core_agent.py` tools.

### 3. `references/prolog_template.md`
Contains the foundational Prolog rules (`facts_tools_rules_actions.pl`) so Gemini CLI doesn't have to search the repository for it every time.

## Phased Implementation Plan

1.  **Initialize Skill:** Run `node <path-to-skill-creator>/scripts/init_skill.cjs autobus-prolog` to generate the skill scaffold.
2.  **Migrate Resources:** 
    *   Copy the DB schema extraction logic from `core_agent.py` into the `scripts/get_db_schema.py` file.
    *   Copy the contents of `prolog-templates/facts_tools_rules_actions.pl` into the `references/` directory.
3.  **Draft SKILL.md:** Write the precise procedural instructions telling Gemini CLI how to execute the Neuro-symbolic workflow.
4.  **Package & Install:** Run `package_skill.cjs`, install the `.skill` file into the local workspace, and have you run `/skills reload`.
5.  **Validation:** Test the skill natively in the CLI by asking: *"Run Task 1: Identify savable churners..."*