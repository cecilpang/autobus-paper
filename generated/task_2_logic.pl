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
outcome_table('median_household_income').

init_db :-
    db_path(DbPath),
    sqlite_connect(DbPath, db,
                   [ exists(true),
                     as_predicates(true),
                     arity(arity)
                   ]).

% -----------------------------
% Call tools via Python function
% -----------------------------

%% median_income_of_city(+City, -MedianIncome:int)
%% Calls Python tool_for_prolog:median_household_income(City) -> MedianIncome
median_income_of_city(City, MedianIncome) :-
    py_call(tool_for_prolog:median_household_income(City), MedianIncome).

% -----------------------------
% Business rules
% -----------------------------

%% subscriber_city(-City)
%% City for each subscriber (active subscriptions), potentially with duplicates.
subscriber_city(City) :-
    subscription(_SubscriptionId, ConsumerId, Status, _SubscriptionRate, _ProductId, _RiskLevel),
    Status = 'Active',
    consumer(ConsumerId, _ConsumerName, City).

%% distinct_subscriber_city(-City)
%% Unique cities where subscribers reside.
distinct_subscriber_city(City) :-
    setof(C, subscriber_city(C), Cities),
    member(City, Cities).

%% outcome_row(-City, -MedianIncome)
%% Compute median household income for each subscriber city.
outcome_row(City, MedianIncome) :-
    distinct_subscriber_city(City),
    median_income_of_city(City, MedianIncome).

% -----------------------------
% Actions
% -----------------------------

%% save_outcome_to_database/0
%% Clears median_household_income then inserts (city, median_household_income).
save_outcome_to_database :-
    outcome_table(OutcomeTable),
    format(atom(DeleteSql), "DELETE FROM ~w;", [OutcomeTable]),
    sqlite_query(db, DeleteSql, _),
    forall(
        outcome_row(City, MedianIncome),
        (
            escape_sql_string(City, EscapedCity),
            outcome_table(OutcomeTable),
            format(atom(InsertSql), "INSERT INTO ~w (city, median_household_income) VALUES ('~w', ~w);", [OutcomeTable, EscapedCity, MedianIncome]),
            sqlite_query(db, InsertSql, _)
        )
    ).

% -----------------------------
% Helpers
% -----------------------------

%% escape_sql_string(+In:string, -Out:atom)
%% Replace single quotes ' with '' for safe SQL single-quoted literal insertion.
escape_sql_string(In, Out) :-
    split_string(In, "'", "'", Parts),
    atomic_list_concat(Parts, "''", Out).

% -----------------------------
% End of file
% -----------------------------
