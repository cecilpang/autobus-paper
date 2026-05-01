Task ID: task_3
Find the target subscriptions that are potentially savable churns and the subscribers' household incomes are more 
than the median of the city. Then send it to the marketing campaign 'campaign 123'.
Action specification:
1. Save the outcome to the database table 'target_subscription'. Include these fields:
    subscription_id, status, product_name, risk_level, subscription_rate, household_income, median_household_income.
2. Call the tool 'tool_simulation:send_to_marketing_campaign' with takes two arguments:
    i. campaign id = 'campaign 123'
    ii. a list of the target subscription ids