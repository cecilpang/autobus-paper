# Evaluation Report - Task 1 (Business Logic)

**Status: PASS**

## Criteria Verification

| Criterion | Requirement | Implementation in `candidate.pl` | Status |
| :--- | :--- | :--- | :--- |
| 1 | Churn risk level is 4 | `subscription(..., 4)` | PASS |
| 2 | Subscription rate >= $10 | `Rate >= 10.0` | PASS |
| 3 | 'Premium Plan' or 'Family Plan' | `(ProductName = 'Premium Plan' ; ProductName = 'Family Plan')` | PASS |
| 4 | Subscription is active | `downcase_atom(Status, active)` | PASS |

## Outcome Verification
- **Fields:** `subscription_id`, `consumer_id` (Mapped to `SubID`, `ConsumerID`). **Verified**.
- **Target Table:** `savable_churn`. **Verified**.

## Findings
The logic is correctly implemented. The use of `downcase_atom/2` for the status check adds robustness against case variations in the database. The joins between the `subscription` and `product` predicates are correct.
