# Implementation Plan: Gemini CLI Skill for Neuro-symbolic AI

## Objective
Create a native Gemini CLI Skill (`autobus-prolog`) that allows the Gemini agent to act as the core reasoning engine for the `autobus-paper` project. This will replace the need for the external `openai-agents` library, allowing users to execute natural language business tasks directly through the Gemini CLI.

## Feasibility Justification
This idea is **highly feasible and architecturally elegant**.
Currently, `core_agent.py` acts as a middleman to an LLM, gathering the database schema and a Prolog template to generate `.pl` files. 
By creating a Gemini CLI Skill, we can transfer this exact procedural knowledge directly into Gemini CLI. 
*   **Context Management:** We can bundle the Prolog template as a `reference` file and use a lightweight `script` to fetch the DB schema on demand.
*   **Execution:** Gemini CLI natively supports executing terminal commands, meaning it can easily run `janus-swi` (via `autobus-prolog/scripts/run_prolog.py`) to execute the generated logic.
*   **Result:** A seamless workflow where you can type "Identify high risk churners" into Gemini CLI, and it will autonomously generate the Prolog logic and execute it against your SQLite DB.

## Skill Architecture (`autobus-prolog` skill)

The skill will be structured as follows:

```text
autobus-prolog/
├── SKILL.md                 # Core instructions on how to translate tasks to Prolog and execute them.
├── scripts/
│   └── get_db_schema.py     # Python script to dump the db.sqlite schema (extracted from core_agent.py)
└── references/
    └── prolog_template.pl   # The contents of facts_tools_rules_actions.pl
```

## Phase 5: Detailed Validation Plan

This phase ensures that the Gemini CLI Skill `autobus-prolog` produces logic equivalent to the original `core_agent.py`. Validation will be performed sequentially for each task using the **exact** original instructions.

### Validation Principles
1.  **Isolation**: Generated files will be saved with a `_skill_test` suffix (e.g., `generated/task_1_logic_skill_test.pl`) to prevent overwriting existing reference files.
2.  **Identical Inputs**: The instructions provided to the Gemini CLI must match the `task_instruction` strings in the original Python scripts exactly.
3.  **Comparison**: Each generated file will be compared against the existing reference file in the `generated/` directory.
4.  **Functional Parity**: The final database state after execution must be consistent with the business requirements.

---

### Step 5.1: Validation of Task 1 (Churn Risk)
*   **Test Prompt**:
    ```text
    Task ID: task_1
    Find savable churn. A subscription is a savable churn if all of the following criteria are met:
    1. The subscription's churn risk level is 4.
    2. The subscription rate is $10 or more.
    3. The subscription is for 'Premium Plan' or 'Family Plan'.
    4. The subscription is active.
    Outcome specification:
    The outcome has two fields: subscription_id, consumer_id
    Save the outcome to the database table 'savable_churn'
    ```
*   **Verification**:
    *   Compare `generated/task_1_logic_skill_test.pl` with `generated/task_1_logic.pl`.
    *   Confirm criteria (risk level 4, rate >= 10, plans, status) are correctly implemented in Prolog predicates.

### Step 5.2: Validation of Task 2 (External Data/Research)
*   **Test Prompt**:
    ```text
    Task ID: task_2
    Find the median household incomes of the cities in which our subscribers reside.
    Obtain the median household income of cities by calling the tool 'tool_simulation:median_household_income',
    passing in the city, expecting an integer returned.
    Outcome specification:
    The outcome has two fields: city, median_household_income.
    Save the outcome to the database table 'median_household_income'.
    ```
*   **Verification**:
    *   Compare `generated/task_2_logic_skill_test.pl` with `generated/task_2_logic.pl`.
    *   Confirm the `py_call` mechanism correctly targets `tool_simulation:median_household_income`.

### Step 5.3: Validation of Task 3 (Join & Action)
*   **Test Prompt**:
    ```text
    Task ID: task_3
    Find the target subscriptions that are potentially savable churns and the subscribers' household incomes are more
    than the median of the city. Then send it to the marketing campaign 'campaign 123'.
    Action specification:
    1. Save the outcome to the database table 'target_subscription'. Include these fields:
     subscription_id, status, product_name, risk_level, subscription_rate, household_income, median_household_income.
    2. Call the tool 'tool_simulation:send_to_marketing_campaign' with takes two arguments:
        i. campaign id = 'campaign 123'
        ii. a list of the target subscription ids
    ```
*   **Verification**:
    *   Compare `generated/task_3_logic_skill_test.pl` with `generated/task_3_logic.pl`.
    *   Confirm join logic between `savable_churn` and `median_household_income`.
    *   Confirm the marketing campaign tool call and arguments are correctly formed.

---

### Success Criteria
- [ ] **Structural Identity**: The logic in `_skill_test.pl` files is functionally identical to reference files.
- [ ] **Execution Success**: Running `uv run autobus-prolog/scripts/run_prolog.py generated/task_N_logic_skill_test.pl` completes without errors.
- [ ] **Data Integrity**: The final tables in `db.sqlite` reflect the intended business outcome.
