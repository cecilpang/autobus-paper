import asyncio
from agents import gen_trace_id, trace
from agent.agent_session import WorkflowContext, AgentSession
from agent.core_agent import core_agent, AGENT_NAME

"""
Task 1: Identify potentially savable churns.
"""

async def main():

    trace_id = gen_trace_id()
    with trace(workflow_name=AGENT_NAME, trace_id=trace_id):

        task_instruction = """
            Task ID: task_1
            Find savable churn. A subscription is a savable churn if all of the following criteria are met:
            1. The subscription's churn risk level is 4.
            2. The subscription rate is $10 or more.
            3. The subscription is for 'Premium Plan' or 'Family Plan'.
            4. The subscription is active.
            Outcome specification:
            The outcome has two fields: subscription_id, consumer_id
            Save the outcome to the database table 'savable_churn'
        """

        print(f"View trace: https://platform.openai.com/traces/trace?trace_id={trace_id}\n")
        agent_session = AgentSession(AGENT_NAME, WorkflowContext(), core_agent)
        r = await agent_session.run(task_instruction)
        print(r)

if __name__ == "__main__":
    asyncio.run(main())