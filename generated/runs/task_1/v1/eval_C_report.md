# Evaluator C Report: Edge Cases & Safety

## 1. SQL Safety (Escaping)
- **Vulnerability / Error Risk:** The `INSERT` statement is constructed using string interpolation with `~w`: 
  `format(atom(SQL), "INSERT INTO ~w (subscription_id, consumer_id) VALUES (~w, ~w);", ...)`.
  - If `SubID` or `ConsumerID` are string-based identifiers (e.g., UUIDs or alphanumeric strings), this will generate invalid SQL because the values are not enclosed in single quotes (e.g., `VALUES (abc, def)` instead of `VALUES ('abc', 'def')`).
  - If these strings could contain arbitrary or untrusted data, this presents a SQL injection vulnerability.
  - **Recommendation:** Ensure strings are properly escaped and quoted (e.g., `VALUES ('~w', '~w')`) if they are alphanumeric. Better yet, use parameterized queries if the database library setup allows for it.

## 2. Handling of Nulls/Missing Data
- **Arithmetic Errors:** In Prolog with `prosqlite`, if a numeric column like `subscription_rate` is `NULL`, it is often returned as the atom `'$null$'` or left as an uninstantiated variable. 
  - Evaluating `Rate >= 10.0` when `Rate` is not a number will result in a runtime `type_error` or `instantiation_error`, crashing the script.
  - **Recommendation:** Guard the arithmetic check with `number(Rate)`, e.g., `number(Rate), Rate >= 10.0`.
- **String Manipulation Errors:** Calling `downcase_atom(Status, active)` could throw a type error if `Status` is uninstantiated (e.g., due to a `NULL` mapping to a variable).
  - **Recommendation:** Add a guard to ensure `Status` is an atom or string before calling `downcase_atom/2`, e.g., `atom(Status)`.

## 3. Logical Edge Cases
- **Float vs. Integer Comparison:** The comparison `Rate >= 10.0` handles float values. Prolog's arithmetic evaluation handles mixed-type comparisons safely. Whether the database yields an integer (`10`) or a float (`10.5`), the comparison will evaluate correctly. This is structurally sound.
- **Case-Insensitive Status Check:** Using `downcase_atom(Status, active)` successfully catches variations in casing like `Active` or `ACTIVE`, robustly handling database data inconsistencies.

## Summary
The business logic is correctly translated, but the implementation lacks critical safeguards against `NULL` database values, which will cause Prolog runtime crashes. Additionally, the raw string formatting in the `INSERT` query makes it prone to syntax errors and SQL injection if the IDs are strings rather than simple integers.