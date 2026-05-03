# QA Skill Development Plan

## 1. Objective
Develop a native Gemini CLI Skill (`qa`) that acts as an independent, automated validation engine. After a task logic is generated and executed (via the `generate-prolog` skill), the QA skill will empirically verify that the resulting state of the SQLite database (`db.sqlite`) strictly matches the business requirements defined in an expected outputs file.

## 2. Architecture & Resources
*   **Skill Location:** `.agent/skills/qa/`
*   **Shared Tools:** The skill will utilize the shared schema extraction script located at `.agent/skills/tools/get_db_schema.py` to understand database relationships without duplicating logic across skills.
*   **Input Data:** The expected outputs file (e.g., `expected-outputs/Task_1_expected_outputs.md`).
*   **Target Data:** The project's SQLite database (`database/db.sqlite`).

## 3. The QA Validation Workflow

The QA skill will operate in a versioned, iterative loop to allow for user feedback and requirement adjustments.

### Step 3.1: Initialization & Context Gathering
*   Identify the target task ID (e.g., `task_1`) from the user prompt.
*   Create a versioned directory for the QA run: `generated/runs/<task_id>/qa_v<N>/` (starting with `qa_v1`).
*   **Gather Schema Context:** Run `python .agent/skills/tools/get_db_schema.py`.
*   **Gather Criteria Context:** Read the expected outputs file (e.g., `expected-outputs/Task_1_expected_outputs.md`).

### Step 3.2: Validation Execution (Script Generation)
Rather than executing isolated shell commands, the agent will generate a cohesive Python test script.
*   **Action:** The agent writes `qa_script.py` inside the `qa_v<N>` directory.
*   **Requirements for `qa_script.py`:**
    *   Must connect to `database/db.sqlite` using the `sqlite3` library.
    *   Must translate the human-readable criteria from the `.md` file into concrete SQL queries.
    *   *Crucial Detail:* For complex criteria (e.g., validating that every record in the output table belongs to a 'Premium Plan'), the script must perform SQL `JOIN` operations back to the original source tables (`subscription`, `product`) to empirically verify the data.
    *   Must evaluate *all* criteria exhaustively (no fail-fast).
    *   Must output structured results indicating Pass/Fail for each individual criterion.
*   **Execution:** Run the generated script: `python generated/runs/<task_id>/qa_v<N>/qa_script.py`.

### Step 3.3: Comprehensive Reporting
*   **Action:** Based on the console output of `qa_script.py`, the agent will compile a detailed Markdown report.
*   **Output:** Save the report to `generated/runs/<task_id>/qa_v<N>/qa_report.md`.
*   The report must explicitly list each criterion, its Pass/Fail status, and any relevant data details (e.g., "Failed: Found 2 subscriptions with rate < $10").

### Step 3.4: Human Approval & Feedback Loop
*   **Action:** Present the contents of `qa_report.md` to the user.
*   **Decision:**
    *   If the user approves, the QA process is complete.
    *   If the user updates the criteria in the `expected_outputs.md` file or provides conversational feedback, the agent must increment the version to `qa_v<N+1>` and restart the process from Step 3.1.

## 4. Implementation Steps
1.  **Draft SKILL.md:** Update `.agent/skills/qa/SKILL.md` to explicitly define the workflow outlined in Section 3. The instructions must guide the LLM to generate the Python `sqlite3` script and handle the versioned feedback loop.
2.  **Package Skill:** Run the `package_skill.cjs` script to create the `qa.skill` artifact.
3.  **Install Skill:** Install the updated `qa.skill` into the workspace scope.
4.  **Reload Context:** Run `/skills reload` in the interactive terminal.
5.  **Test Execution:** Execute the skill using `Task_1_expected_outputs.md` against the results generated in Task 1 to verify the validation script generation and reporting works correctly.
