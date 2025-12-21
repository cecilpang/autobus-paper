import asyncio
from agents import gen_trace_id, trace
from util.agent_session import WorkflowContext, AgentSession
from agent.core_agent import core_agent, AGENT_NAME

"""
Task 3: Find the target subscriptions that are potentially savable churns and the subscribers' household incomes are more than
the median of the city.
"""

async def main():

    trace_id = gen_trace_id()
    with trace(workflow_name=AGENT_NAME, trace_id=trace_id):

        task_instruction = """
            Task ID: task_3
            Find the target subscriptions that are potentially savable churns and the subscribers' household incomes are more 
            than the median of the city. Then send it to the marketing campaign 'campaign 123'.
            Action specification:
            1. Save the outcome to the database table 'target_subscription'. Include these fields:
             subscription_id, status, product_name, risk_level, subscription_rate, household_income, median_household_income.
            2. Call the tool 'tool_simulation:send_to_marketing_campaign' with takes two arguments:
                i. campaign id = 'campaign 123'
                ii. a list of the target subscription ids 
        """

        print(f"View trace: https://platform.openai.com/traces/trace?trace_id={trace_id}\n")
        agent_session = AgentSession(AGENT_NAME, WorkflowContext(), core_agent)
        r = await agent_session.run(task_instruction)
        print(r)

if __name__ == "__main__":
    asyncio.run(main())