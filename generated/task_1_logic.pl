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

% After sqlite_connect/3 with as_predicates(true),
% the tables become predicates:
%   subscription(SubscriptionId, ConsumerId, Status, SubscriptionRate, ProductId, RiskLevel)
%   product(ProductId, ProductName, StandardRate)
%   savable_churn(SubscriptionId, ConsumerId)

% -----------------------------
% Business rules
% -----------------------------

%% savable_churn_subscription(+SubscriptionId, -ConsumerId)
%% True if a subscription meets all criteria for "savable churn":
%% 1) risk_level = 4
%% 2) subscription_rate >= 10
%% 3) product_name in {'Premium Plan','Family Plan'}
%% 4) status = 'Active'

savable_churn_subscription(SubscriptionId, ConsumerId) :-
    subscription(SubscriptionId, ConsumerId, Status, SubscriptionRate, ProductId, RiskLevel),
    RiskLevel =:= 4,
    SubscriptionRate >= 10,
    Status == 'Active',
    product(ProductId, ProductName, _StandardRate),
    (ProductName == 'Premium Plan' ; ProductName == 'Family Plan').

% -----------------------------
% Actions
% -----------------------------

%% save_outcome_to_database/0
%% Clears savable_churn then inserts (subscription_id, consumer_id) for each qualifying subscription.
save_outcome_to_database :-
    outcome_table(OutcomeTable),
    format(atom(DeleteSql), "DELETE FROM ~w;", [OutcomeTable]),
    sqlite_query(db, DeleteSql, _),
    forall(
        savable_churn_subscription(SubscriptionId, ConsumerId),
        (
            outcome_table(OutcomeTable),
            format(atom(InsertSql), "INSERT INTO ~w(subscription_id, consumer_id) VALUES (~w, ~w);", [OutcomeTable, SubscriptionId, ConsumerId]),
            sqlite_query(db, InsertSql, _)
        )
    ).

% -----------------------------
% End of file
% -----------------------------
