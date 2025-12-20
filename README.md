## Paper: Autonomous Business System via Neuro-symbolic AI
#### Please refer to the Validation Case Study section of the paper.
The AI agents use OpenAI's LLMs: https://platform.openai.com/docs/models<br/>
The logic engine under the hood is SWI-Prolog: https://www.swi-prolog.org/

### To run the demo:
1. Install uv: https://github.com/astral-sh/uv
2. Clone this repo and cd into the project directory.
```
git clone https://github.com/cecilpang/autobus.git
cd autobus
```
3. Place your OpenAI API key in a file named '.env' at the project directory. There should be one line in .env like this:</br>
OPENAI_API_KEY=your OpenAI key

4. Create sample data. A sqlite database file 'db.sqlite' will be created in the sub-directory database/</br>
```uv run src/create_sample_data.py```
5. Execute Task 1:</br>
AI agent generates a logic program:<br/>
```uv run --env-file .env --script src/task_1.py```</br>
Execute the logic program:<br/>
```uv run --script src/run_prolog.py generated-pl-programs/task_1_logic.pl```