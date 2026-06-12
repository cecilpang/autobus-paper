## Paper: Validation of Neuro-symbolic Autonomous Business System
#### Please refer to the Case Study section of the paper.
The logic engine under the hood is SWI-Prolog: https://www.swi-prolog.org/

### To run the case study:
1. Install uv: https://github.com/astral-sh/uv
2. Install Google Gemini CLI: https://geminicli.com/docs/get-started/installation/
3. Clone this repo and checkout the "agentic-coding" branch:
    ```
    git clone https://github.com/cecilpang/autobus-paper.git
    cd autobus-paper
    git checkout agentic-coding
    ```
4. Place your Gemini API key in the file `.env` at the project directory. There should be one line in `.env`:
    ```
    GEMINI_API_KEY=<your Gemini key>
    ```
5. Create sample data. A sqlite database file 'db.sqlite' will be created in the sub-directory `database`.
    ```
    uv run --script src/create_sample_data.py
    ```
6. Execute the 3 tasks. Task 1 and 2 can run in parallel. Task 3 depends on the outcomes of Tasks 1 and 2.

    Task 1:
    ```
    gemini "Run task 1 using the instructions in tasks/Task_1.md"
    ```
    Task 2:
    ```
    gemini "Run task 2 using the instructions in tasks/Task_2.md"
    ```
    Task 3:
    ```
    gemini "Run task 3 using the instructions in tasks/Task_3.md"
    ```
7. Execute QA workflow for task 1:
    ```
    gemini "Run qa skill using the instructions in expected-outputs/Task_1_expected_outputs.md"
    ```
