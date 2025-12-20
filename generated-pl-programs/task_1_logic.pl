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
    sqlite_disconnect(db).

% -----------------------------
% Database initialization 
% -----------------------------

db_path('database/db.sqlite').
outcome_table('savable_churn').

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

% With sqlite_connect/3 + as_predicates(true), tables become predicates:
%   consumer(ConsumerId, ConsumerName, City)
%   product(ProductId, ProductName, StandardRate)
%   profile_attribute(ConsumerId, AttributeName, AttributeValue)
%   subscription(SubscriptionId, ConsumerId, Status, SubscriptionRate, ProductId, RiskLevel)
%   savable_churn(SubscriptionId, ConsumerId)

% -----------------------------
% Business rules
% -----------------------------

%% savable_churn_row(?SubscriptionId, ?ConsumerId)
%% A subscription is a savable churn if:
%% 1) risk_level = 4
%% 2) subscription_rate >= 10
%% 3) product is 'Premium Plan' or 'Family Plan'
%% 4) status is 'Active'

savable_churn_row(SubscriptionId, ConsumerId) :-
    subscription(SubscriptionId,
                 ConsumerId,
                 'Active',
                 SubscriptionRate,
                 ProductId,
                 4),
    SubscriptionRate >= 10,
    product(ProductId, ProductName, _StandardRate),
    savable_plan_name(ProductName).

savable_plan_name('Premium Plan').
savable_plan_name('Family Plan').

% -----------------------------
% Actions
% -----------------------------

%% save_outcome_to_database/0
%% Clears savable_churn then inserts (subscription_id, consumer_id)
%% for every subscription that satisfies savable_churn_row/2.
save_outcome_to_database :-
    outcome_table(OutcomeTable),
    format(atom(DeleteSql), "DELETE FROM ~w;", [OutcomeTable]),
    sqlite_query(db, DeleteSql, _),

    forall(
        savable_churn_row(SubscriptionId, ConsumerId),
        (
            outcome_table(OutcomeTable),
            format(atom(InsertSql),
                   "INSERT INTO ~w(subscription_id, consumer_id) VALUES (~w, ~w);",
                   [OutcomeTable, SubscriptionId, ConsumerId]),
            sqlite_query(db, InsertSql, _)
        )
    ).

% -----------------------------
% End of file
% -----------------------------
