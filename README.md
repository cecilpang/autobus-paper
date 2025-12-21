## Paper: Autonomous Business System via Neuro-symbolic AI
#### Please refer to the Validation Case Study section of the paper.
The AI agents use OpenAI's LLMs: https://platform.openai.com/docs/models<br/>
The logic engine under the hood is SWI-Prolog: https://www.swi-prolog.org/

### To run the demo:
1. Install uv: https://github.com/astral-sh/uv
2. Clone this repo and cd into the project directory.
    ```
    git clone https://github.com/cecilpang/autobus-paper.git
    cd autobus-paper
    ```
3. Place your OpenAI API key in a file named '.env' at the project directory. There should be one line in .env:
    ```
    OPENAI_API_KEY=your OpenAI key
    ```
4. Create sample data. A sqlite database file 'db.sqlite' will be created in sub-directory database.
    ```
    uv run --script src/create_sample_data.py
    ```
5. Execute the 3 tasks. Task 1 and 2 can run in parallel. Task 3 depends on the outcomes of Tasks 1 and 2.</br>
Each task comprises two steps:</br>
   1. Invoke the AUTOBUS core AI agent to generate a Prolog program
   2. Execute the generated Prolog program

    Task 1:
    ```
    uv run --env-file .env --script src/task_1.py
    uv run --script src/run_prolog.py generated/task_1_logic.pl
    ```
    Task 2:
    ```
    uv run --env-file .env --script src/task_2.py
    uv run --script src/run_prolog.py generated/task_2_logic.pl
    ```
    Task 3:
    ```
    uv run --env-file .env --script src/task_3.py
    uv run --script src/run_prolog.py generated/task_3_logic.pl
    ```