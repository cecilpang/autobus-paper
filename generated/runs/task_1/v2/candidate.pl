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
% Business rules
% -----------------------------

%% savable_churn_row(?SubID, ?ConsumerID)
%% 1. The subscription's churn risk level is 4.
%% 2. The subscription rate is $10 or more.
%% 3. The subscription is for 'Premium Plan' or 'Family Plan'.
%% 4. The subscription is active.
savable_churn_row(SubID, ConsumerID) :-
    % subscription(subscription_id, consumer_id, status, subscription_rate, product_id, risk_level)
    subscription(SubID, ConsumerID, Status, Rate, ProductID, 4),
    % Safety guard: check if Status is an atom (not NULL/variable)
    atom(Status),
    downcase_atom(Status, active),
    % Safety guard: check if Rate is a number (not NULL/variable)
    number(Rate),
    Rate >= 10.0,
    % product(product_id, product_name, standard_rate)
    product(ProductID, ProductName, _),
    (ProductName = 'Premium Plan' ; ProductName = 'Family Plan').

% -----------------------------
% Actions
% -----------------------------

%% save_outcome_to_database/0
%% Clears outcome_table then copies every row from savable_churn_row into output_table.
save_outcome_to_database :-
    % remove existing rows from output table
    outcome_table(OutcomeTable),
    format(atom(DeleteSql), "DELETE FROM ~w;", [OutcomeTable]),
    sqlite_query(db, DeleteSql, _),

    % iterate rows and insert them into output_table
    forall( savable_churn_row(SubID, ConsumerID),
            (
                outcome_table(OutcomeTable),
                % SQL Safety: Quote values in case they are treated as strings or identifiers
                format(atom(SQL), "INSERT INTO ~w (subscription_id, consumer_id) VALUES ('~w', '~w');", [OutcomeTable, SubID, ConsumerID]),
                sqlite_query(db, SQL, _)
            )
          ).

% -----------------------------
% End of file
% -----------------------------
