## **My initial level**<br>
I knew nothing about solidity programming or contract writing or web3/blockchain. I learned everything from scratch in this project!

## **Things I did**
### 1. Secure Contribution System with Deadline & Target Logic
- Users can contribute ETH using `sendEth()`.
- Enforces a minimum contribution and restricts contributions after the deadline.
- Tracks unique contributors and total funds raised.
- `receive()` and `fallback()` functions allow direct ETH transfers to the contract.

---

### 2. Robust Refund Mechanism with Reentrancy Protection
- Contributors can claim a refund if the target is not met after the deadline.
- Implemented a custom `noReentrancy` modifier to secure withdrawals.
- Resets contributor balance before transferring ETH to prevent double withdrawals.

---

### 3. Request-Based Fund Allocation via DAO-style Voting
- The manager can create spending requests with a description, recipient, and amount.
- Contributors vote on each request using `voteRequest()`.
- Funds are released via `makePayment()` only if more than 50% of contributors approve.
- Prevents misuse of funds and promotes decentralized decision-making.

---

### 4. Event Logging for Transparency & Auditing
- Emitted events for: contributions, refunds, request creation, votes, and fund transfers.
- Ensures transparent tracking and auditability of key contract actions.

---

### 5. Security & Access Control Best Practices
- Used `onlyManager` modifier to restrict access to administrative functions.
- Used `require` statements extensively to validate inputs and conditions.
- Organized request data using `struct` and mappings for efficient management.
- Applied defensive programming practices to ensure safety and clarity.


## **Things Learned**
1. Tech : Metamask, RemixIDE, Solidity programming
2. Importance and implementation of require function and reentrancy
3. Learned to build simple and secure smart contracts
