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
% Tool calls (via Python)
% -----------------------------

%% median_household_income_tool(+City, -MedianIncome)
%% Calls tool_simulation:median_household_income(City) -> integer MedianIncome
median_household_income_tool(City, MedianIncome) :-
    py_call(tool_simulation:median_household_income(City), MedianIncome).

% -----------------------------
% Rules
% -----------------------------

%% subscriber_city(-City)
%% City in which at least one subscriber (consumer with a subscription) resides.
subscriber_city(City) :-
    subscription(_SubscriptionId, ConsumerId, _Status, _SubscriptionRate, _ProductId, _RiskLevel),
    consumer(ConsumerId, _ConsumerName, City),
    City \= null.

%% outcome_row(-City, -MedianIncome)
%% One row per distinct subscriber city with its median household income.
outcome_row(City, MedianIncome) :-
    setof(C, subscriber_city(C), Cities),
    member(City, Cities),
    median_household_income_tool(City, MedianIncome).

% -----------------------------
% Actions
% -----------------------------

%% save_outcome_to_database/0
%% Clears median_household_income then inserts (city, median_household_income).
save_outcome_to_database :-
    outcome_table(OutcomeTable),
    format(atom(DeleteSql), "DELETE FROM ~w;", [OutcomeTable]),
    sqlite_query(db, DeleteSql, _),
    forall( outcome_row(City, MedianIncome),
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

escape_sql_string(In, Out) :-
    split_string(In, "'", "'", Parts),
    atomic_list_concat(Parts, "''", Out).
