import asyncio
from agents import gen_trace_id, trace
from util.agent_session import WorkflowContext, AgentSession
from agent.core_agent import core_agent, AGENT_NAME

"""
Task 2: Find the median household incomes of the cities of the subscribers
"""

async def main():

    trace_id = gen_trace_id()
    with trace(workflow_name=AGENT_NAME, trace_id=trace_id):

        task_instruction = """
            Task ID: task_2
            Find the median household incomes of the cities in which our subscribers reside.
            Obtain the median household income of cities by calling the tool 'tool_simulation:median_household_income', 
            passing in the city, expecting an integer returned.
            Outcome specification:
            The outcome has two fields: city, median_household_income.
            Save the outcome to the database table 'median_household_income'.
        """

        print(f"View trace: https://platform.openai.com/traces/trace?trace_id={trace_id}\n")
        agent_session = AgentSession(AGENT_NAME, WorkflowContext(), core_agent)
        r = await agent_session.run(task_instruction)
        print(r)

if __name__ == "__main__":
    asyncio.run(main())