## Paper: Validation of Neuro-symbolic Autonomous Business System
#### Please refer to the Case Study section of the paper.
The logic engine under the hood is SWI-Prolog: https://www.swi-prolog.org/

### To run the case study:
1. Install SWI-Prolog: https://www.swi-prolog.org/
2. Install uv: https://github.com/astral-sh/uv
3. Install Google Gemini CLI: https://geminicli.com/docs/get-started/installation/
4. Clone this repo and checkout the "agentic-coding" branch:
    ```
    git clone https://github.com/cecilpang/autobus-paper.git
    cd autobus-paper
    git checkout agentic-coding
    ```
5. Place your Gemini API key in the file `.env` at the project directory. There should be one line in `.env`:
    ```
    GEMINI_API_KEY=<your Gemini key>
    ```
6. Create sample data. A sqlite database file 'db.sqlite' will be created in the sub-directory `database`.
    ```
    uv sync
    uv run --script src/create_sample_data.py
    ```
7. Execute the 3 tasks. Task 1 and 2 can run in parallel. Task 3 depends on the outcomes of Tasks 1 and 2.

    Task 1:
    ```
    gemini "Run skill generate-prolog using the instructions in tasks/Task_1.md"
    ```
    Task 2:
    ```
    gemini "Run skill generate-prolog using the instructions in tasks/Task_2.md"
    ```
    Task 3:
    ```
    gemini "Run skill generate-prolog using the instructions in tasks/Task_3.md"
    ```

