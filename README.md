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
3. Place your OpenAI API key in the file `.env` at the project directory. There should be one line in `.env`:
    ```
    OPENAI_API_KEY=<your OpenAI key>
    ```
4. Create sample data. A sqlite database file 'db.sqlite' will be created in the sub-directory `database`.
    ```
    uv run --script src/create_sample_data.py
    ```
5. Execute the 3 tasks. Task 1 and 2 can run in parallel. Task 3 depends on the outcomes of Tasks 1 and 2.
Use the Gemini CLI with the `autobus-prolog` skill to execute each task by pointing it to the respective task instruction file in `tasks/`.

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