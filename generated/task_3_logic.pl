:- use_module(library(prosqlite)).

% Optional: still allow running as a script
:- initialization(main).

% -----------------------------
% Public entry point
% -----------------------------

%% main/0
%% Entry point to run the program
main :-
    init_db,
    save_outcome_to_database,
    send_targets_to_marketing_campaign,
    sqlite_disconnect(db).

% -----------------------------
% Database initialization
% -----------------------------

db_path('database/db.sqlite').
outcome_table('target_subscription').
campaign_id('campaign 123').

init_db :-
    db_path(DbPath),
    sqlite_connect(DbPath, db,
                   [ exists(true),
                     as_predicates(true),
                     arity(arity)
                   ]).

% -----------------------------
% Table-as-predicate
% -----------------------------

% After sqlite_connect/3 with as_predicates(true), tables become predicates:
% consumer(ConsumerId, ConsumerName, City)
% median_household_income(City, MedianHouseholdIncome)
% product(ProductId, ProductName, StandardRate)
% profile_attribute(ConsumerId, AttributeName, AttributeValue)
% savable_churn(SubscriptionId, ConsumerId)
% subscription(SubscriptionId, ConsumerId, Status, SubscriptionRate, ProductId, RiskLevel)
% target_subscription(SubscriptionId, Status, ProductName, RiskLevel, SubscriptionRate, HouseholdIncome, MedianHouseholdIncome)

% -----------------------------
% Tools
% -----------------------------

%% send_to_marketing_campaign(+CampaignId, +SubscriptionIdList)
%% Calls external tool: tool_simulation:send_to_marketing_campaign(CampaignId, List)
send_to_marketing_campaign(CampaignId, SubscriptionIds) :-
    py_call(tool_simulation:send_to_marketing_campaign(CampaignId, SubscriptionIds), _).

% -----------------------------
% Business rules
% -----------------------------

%% household_income(+ConsumerId, -HouseholdIncomeInt)
%% Reads household income from profile_attribute table.
%% Expected attribute_name = 'household_income', attribute_value is numeric text.
household_income(ConsumerId, HouseholdIncome) :-
    profile_attribute(ConsumerId, 'household_income', IncomeText),
    atom_number(IncomeText, HouseholdIncome).

%% consumer_city_median_income(+ConsumerId, -City, -MedianIncome)
consumer_city_median_income(ConsumerId, City, MedianIncome) :-
    consumer(ConsumerId, _Name, City),
    median_household_income(City, MedianIncome).

%% potentially_savable_churn_subscription(-SubscriptionId, -Status, -ProductName, -RiskLevel, -SubscriptionRate, -HouseholdIncome, -MedianIncome)
%% Criteria:
%% 1) Subscription is in savable_churn
%% 2) Subscriber household income > city median household income
potentially_savable_churn_subscription(SubscriptionId, Status, ProductName, RiskLevel, SubscriptionRate, HouseholdIncome, MedianIncome) :-
    savable_churn(SubscriptionId, ConsumerId),
    subscription(SubscriptionId, ConsumerId, Status, SubscriptionRate, ProductId, RiskLevel),
    product(ProductId, ProductName, _StandardRate),
    household_income(ConsumerId, HouseholdIncome),
    consumer_city_median_income(ConsumerId, _City, MedianIncome),
    HouseholdIncome > MedianIncome.

% -----------------------------
% Actions
% -----------------------------

%% save_outcome_to_database/0
%% Clears target_subscription then inserts all qualifying target subscriptions.
save_outcome_to_database :-
    outcome_table(OutcomeTable),
    format(atom(DeleteSql), "DELETE FROM ~w;", [OutcomeTable]),
    sqlite_query(db, DeleteSql, _),
    forall(
        potentially_savable_churn_subscription(SubscriptionId, Status, ProductName, RiskLevel, SubscriptionRate, HouseholdIncome, MedianIncome),
        (
            escape_sql_string(Status, EscStatus),
            escape_sql_string(ProductName, EscProductName),
            outcome_table(OutcomeTable),
            format(atom(InsertSql),
                   "INSERT INTO ~w (subscription_id, status, product_name, risk_level, subscription_rate, household_income, median_household_income) VALUES (~w, '~w', '~w', ~w, ~w, ~w, ~w);",
                   [OutcomeTable, SubscriptionId, EscStatus, EscProductName, RiskLevel, SubscriptionRate, HouseholdIncome, MedianIncome]),
            sqlite_query(db, InsertSql, _)
        )
    ).

%% send_targets_to_marketing_campaign/0
%% Collect ids from target_subscription and send to campaign tool.
send_targets_to_marketing_campaign :-
    campaign_id(CampaignId),
    findall(SubscriptionId, target_subscription(SubscriptionId, _Status, _ProductName, _RiskLevel, _SubscriptionRate, _HouseholdIncome, _MedianIncome), Ids),
    sort(Ids, UniqueIds),
    send_to_marketing_campaign(CampaignId, UniqueIds).

% -----------------------------
% Helpers
% -----------------------------

%% escape_sql_string(+In, -Out)
%% Replace single quotes ' with '' for safe SQL single-quoted literal insertion.
escape_sql_string(In, Out) :-
    split_string(In, "'", "'", Parts),
    atomic_list_concat(Parts, "''", Out).

% -----------------------------
% End of file
% -----------------------------
