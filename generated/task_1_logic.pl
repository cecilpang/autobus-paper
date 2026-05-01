:- use_module(library(prosqlite)).

:- initialization(main).

% -----------------------------
% Public entry point
% -----------------------------
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
% Business rules
% -----------------------------

%% savable_churn_candidate(-SubscriptionId, -ConsumerId)
savable_churn_candidate(SubscriptionId, ConsumerId) :-
    % 1. The subscription's churn risk level is 4
    % 2. The subscription rate is $10 or more
    % 4. The subscription is active
    subscription(SubscriptionId, ConsumerId, 'Active', SubscriptionRate, ProductId, 4),
    SubscriptionRate >= 10,
    
    % 3. The subscription is for 'Premium Plan' or 'Family Plan'
    product(ProductId, ProductName, _),
    ( ProductName = 'Premium Plan' ; ProductName = 'Family Plan' ).

% -----------------------------
% Actions
% -----------------------------

save_outcome_to_database :-
    outcome_table(OutcomeTable),
    format(atom(DeleteSql), "DELETE FROM ~w;", [OutcomeTable]),
    sqlite_query(db, DeleteSql, _),
    
    forall( savable_churn_candidate(SubscriptionId, ConsumerId),
            (
                format(atom(SQL), "INSERT INTO ~w (subscription_id, consumer_id) VALUES (~w, ~w);", [OutcomeTable, SubscriptionId, ConsumerId]),
                sqlite_query(db, SQL, _)
            )
          ).