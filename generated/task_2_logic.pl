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

%% median_household_income_for_city(+City, -Income)
%% Calls Python tool_for_prolog:median_household_income(City) -> Income (integer)
median_household_income_for_city(City, Income) :-
    py_call(tool_for_prolog:median_household_income(City), Income).

% -----------------------------
% Business rules
% -----------------------------

%% subscriber_city(-City)
%% City where at least one subscriber (consumer with a subscription) resides.
subscriber_city(City) :-
    subscription(_SubscriptionId, ConsumerId, _Status, _SubscriptionRate, _ProductId, _RiskLevel),
    consumer(ConsumerId, _ConsumerName, City).

%% distinct_subscriber_city(-City)
%% Deduplicated city list.
distinct_subscriber_city(City) :-
    setof(C, subscriber_city(C), Cities),
    member(City, Cities).

% -----------------------------
% Actions
% -----------------------------

%% save_outcome_to_database/0
%% Clears median_household_income then inserts (city, median_household_income)
%% for each city where our subscribers reside.
save_outcome_to_database :-
    outcome_table(OutcomeTable),
    format(atom(DeleteSql), "DELETE FROM ~w;", [OutcomeTable]),
    sqlite_query(db, DeleteSql, _),
    forall( distinct_subscriber_city(City),
            (
                median_household_income_for_city(City, Income),
                escape_sql_string(City, EscapedCity),
                outcome_table(OutcomeTable),
                format(atom(SQL), "INSERT INTO ~w(city, median_household_income) VALUES ('~w', ~w);", [OutcomeTable, EscapedCity, Income]),
                sqlite_query(db, SQL, _)
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
