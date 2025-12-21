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

% Tables exposed as predicates by prosqilte (as_predicates(true)):
%   consumer(consumer_id, consumer_name, city)
%   product(product_id, product_name, standard_rate)
%   profile_attribute(consumer_id, attribute_name, attribute_value)
%   subscription(subscription_id, consumer_id, status, subscription_rate, product_id, risk_level)
%   savable_churn(subscription_id, consumer_id)

% -----------------------------
% Business rules
% -----------------------------

%% eligible_plan_product(+ProductId)
%% True when the product is Premium Plan or Family Plan.
eligible_plan_product(ProductId) :-
    product(ProductId, ProductName, _StandardRate),
    ( ProductName = 'Premium Plan'
    ; ProductName = 'Family Plan'
    ).

%% savable_churn_row(-SubscriptionId, -ConsumerId)
%% A subscription is a savable churn if:
%%  1) risk_level = 4
%%  2) subscription_rate >= 10
%%  3) product_name in {Premium Plan, Family Plan}
%%  4) status = 'Active'
%
savable_churn_row(SubscriptionId, ConsumerId) :-
    subscription(SubscriptionId, ConsumerId, Status, SubscriptionRate, ProductId, RiskLevel),
    RiskLevel =:= 4,
    SubscriptionRate >= 10,
    Status = 'Active',
    eligible_plan_product(ProductId).

% -----------------------------
% Actions
% -----------------------------

%% save_outcome_to_database/0
%% Clears savable_churn then inserts all (subscription_id, consumer_id)
%% that satisfy savable_churn_row/2.
save_outcome_to_database :-
    % remove existing rows from output table
    outcome_table(OutcomeTable),
    format(atom(DeleteSql), "DELETE FROM ~w;", [OutcomeTable]),
    sqlite_query(db, DeleteSql, _),

    % insert new rows
    forall( savable_churn_row(SubscriptionId, ConsumerId),
            (
                outcome_table(OutcomeTable),
                format(atom(SQL),
                       "INSERT INTO ~w(subscription_id, consumer_id) VALUES (~w, ~w);",
                       [OutcomeTable, SubscriptionId, ConsumerId]),
                sqlite_query(db, SQL, _)
            )
          ).

% -----------------------------
% End of file
% -----------------------------
