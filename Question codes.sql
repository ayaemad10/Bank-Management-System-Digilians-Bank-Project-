USE Digilians_Bank;
GO


-- Q1: Customer Master View
CREATE OR ALTER VIEW vw_CustomerMaster_J AS
SELECT
    c.customer_id,
    c.first_name + ' ' + c.last_name  AS FullName,
    c.national_id,
    c.phone,
    c.email,
    c.city,
    COUNT(a.account_id)               AS TotalAccounts,
    ISNULL(SUM(a.balance_usd), 0)     AS TotalBalance
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name,
         c.national_id, c.phone, c.email, c.city;
GO

SELECT TOP 20 * FROM vw_CustomerMaster_J
ORDER BY TotalBalance DESC;
GO


-- Q2: Account Portfolio View
CREATE OR ALTER VIEW vw_AccountPortfolio_J AS
SELECT
    a.account_id                        AS AccountNo,
    c.first_name + ' ' + c.last_name    AS CustomerName,
    b.branch_name                       AS BranchName,
    a.account_type,
    a.open_date                         AS OpenedOn,
    a.status,
    a.balance_usd                       AS Balance
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
JOIN branches  b ON a.branch_id   = b.branch_id;
GO

SELECT * FROM vw_AccountPortfolio_J
WHERE status != 'active'
ORDER BY OpenedOn DESC;
GO


-- Q3: Monthly Transaction Summary
SELECT
    FORMAT(transaction_date, 'yyyy-MM')                                        AS YearMonth,
    SUM(CASE WHEN transaction_type = 'credit' THEN amount_usd ELSE 0 END)      AS TotalCredit,
    SUM(CASE WHEN transaction_type = 'debit'  THEN amount_usd ELSE 0 END)      AS TotalDebit,
    SUM(CASE WHEN transaction_type = 'credit' THEN  amount_usd
             WHEN transaction_type = 'debit'  THEN -amount_usd
             ELSE 0 END)                                                        AS NetFlow,
    COUNT(*)                                                                    AS TxnCount
FROM transactions
WHERE transaction_date >= DATEADD(MONTH, -12, GETDATE())
GROUP BY FORMAT(transaction_date, 'yyyy-MM')
ORDER BY YearMonth;
GO


-- Q4: Customer Statement View
CREATE OR ALTER VIEW vw_CustomerStatement_J AS
SELECT
    c.customer_id,
    c.first_name + ' ' + c.last_name   AS CustomerName,
    a.account_id                        AS AccountNo,
    t.transaction_date                  AS TxnDateTime,
    t.transaction_type                  AS TxnType,
    t.amount_usd                        AS Amount,
    t.description
FROM transactions t
JOIN accounts  a ON t.account_id  = a.account_id
JOIN customers c ON a.customer_id = c.customer_id;
GO

SELECT * FROM vw_CustomerStatement_J
WHERE customer_id  = 'CU001'
  AND TxnDateTime >= DATEADD(MONTH, -12, GETDATE())
  AND TxnDateTime <= GETDATE()
ORDER BY TxnDateTime DESC;
GO


-- Q5: Top 10 Customers by Activity
SELECT TOP 10
    c.customer_id,
    c.first_name + ' ' + c.last_name                                           AS CustomerName,
    COUNT(t.transaction_id)                                                     AS TxnCount,
    SUM(CASE WHEN t.transaction_type = 'credit' THEN t.amount_usd ELSE 0 END)  AS TotalCredit,
    SUM(CASE WHEN t.transaction_type = 'debit'  THEN t.amount_usd ELSE 0 END)  AS TotalDebit,
    SUM(CASE WHEN t.transaction_type = 'credit' THEN  t.amount_usd
             WHEN t.transaction_type = 'debit'  THEN -t.amount_usd
             ELSE 0 END)                                                        AS NetFlow,
    ROW_NUMBER() OVER (ORDER BY COUNT(t.transaction_id) DESC)                  AS RowNum,
    DENSE_RANK() OVER (ORDER BY COUNT(t.transaction_id) DESC)                  AS DenseRank
FROM customers c
JOIN accounts     a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id  = t.account_id
WHERE t.transaction_date >= DATEADD(DAY, -90, GETDATE())
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY TxnCount DESC;
GO


-- Q6: Branch Performance View
CREATE OR ALTER VIEW vw_BranchPerformance_J AS
SELECT
    b.branch_name,
    COUNT(DISTINCT a.customer_id)                                              AS CustomersCount,
    COUNT(t.transaction_id)                                                    AS TxnCount,
    ISNULL(SUM(t.amount_usd), 0)                                               AS TotalTxnValue,
    ISNULL(SUM(CASE WHEN t.transaction_type = 'credit' THEN  t.amount_usd
                    WHEN t.transaction_type = 'debit'  THEN -t.amount_usd
                    ELSE 0 END), 0)                                            AS NetFlow
FROM branches b
LEFT JOIN accounts     a ON b.branch_id  = a.branch_id
LEFT JOIN transactions t ON a.account_id = t.account_id
       AND t.transaction_date >= DATEADD(DAY, -30, GETDATE())
GROUP BY b.branch_id, b.branch_name;
GO

SELECT * FROM vw_BranchPerformance_J
ORDER BY NetFlow DESC;
GO


-- Q7: Top 10 Employees by Activity
SELECT TOP 10
    e.first_name + ' ' + e.last_name   AS EmployeeName,
    e.role,
    b.branch_name,
    COUNT(t.transaction_id)            AS TxnHandled,
    SUM(t.amount_usd)                  AS TotalValueHandled
FROM employees e
JOIN branches     b ON e.branch_id   = b.branch_id
JOIN transactions t ON e.employee_id = t.employee_id
WHERE t.transaction_date >= DATEADD(DAY, -30, GETDATE())
GROUP BY e.employee_id, e.first_name, e.last_name, e.role, b.branch_name
ORDER BY TxnHandled DESC;
GO


-- Q8: Service Adoption View
CREATE OR ALTER VIEW vw_ServiceAdoption_J AS
SELECT
    c.customer_id,
    c.first_name + ' ' + c.last_name                                           AS CustomerName,
    COUNT(CASE WHEN cs.status = 'active' THEN 1 END)                           AS ActiveServicesCount,
    STRING_AGG(CASE WHEN cs.status = 'active' THEN s.service_name END, ', ')   AS ServicesList
FROM customers c
LEFT JOIN customer_services cs ON c.customer_id = cs.customer_id
LEFT JOIN services           s  ON cs.service_id = s.service_id
GROUP BY c.customer_id, c.first_name, c.last_name;
GO

SELECT * FROM vw_ServiceAdoption_J
WHERE ActiveServicesCount >= 2
ORDER BY ActiveServicesCount DESC;
GO


-- Q9: Inactive Accounts
SELECT
    a.account_id                        AS AccountNo,
    c.first_name + ' ' + c.last_name    AS CustomerName,
    b.branch_name,
    a.balance_usd,
    MAX(t.transaction_date)             AS LastTxnDate,
    DATEDIFF(DAY, MAX(t.transaction_date), GETDATE()) AS DaysSinceLastTxn
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
JOIN branches  b ON a.branch_id   = b.branch_id
LEFT JOIN transactions t ON a.account_id = t.account_id
WHERE a.is_active = 1
GROUP BY a.account_id, c.first_name, c.last_name, b.branch_name, a.balance_usd
HAVING MAX(t.transaction_date) < DATEADD(DAY, -60, GETDATE())
    OR MAX(t.transaction_date) IS NULL
ORDER BY DaysSinceLastTxn DESC;
GO


-- Q10: Suspicious Transactions
SELECT * FROM (
    SELECT
        t.transaction_id,
        a.account_id                        AS AccountNo,
        c.first_name + ' ' + c.last_name    AS CustomerName,
        b.branch_name,
        t.transaction_type,
        t.amount_usd,
        t.transaction_date,
        CASE
            WHEN t.amount_usd > (SELECT AVG(t2.amount_usd) + 3 * STDEV(t2.amount_usd)
                                 FROM transactions t2
                                 JOIN accounts a2 ON t2.account_id = a2.account_id
                                 WHERE a2.branch_id = b.branch_id)
             AND t.transaction_type = 'debit'
             AND t.amount_usd > a.balance_usd * 0.8
            THEN 'High amount + Large debit'
            WHEN t.amount_usd > (SELECT AVG(t2.amount_usd) + 3 * STDEV(t2.amount_usd)
                                 FROM transactions t2
                                 JOIN accounts a2 ON t2.account_id = a2.account_id
                                 WHERE a2.branch_id = b.branch_id)
            THEN 'High amount: exceeds AVG + 3x STDEV'
            WHEN t.transaction_type = 'debit'
             AND t.amount_usd > a.balance_usd * 0.8
            THEN 'Large debit: exceeds 80% of balance'
        END AS FlagReason
    FROM transactions t
    JOIN accounts  a ON t.account_id  = a.account_id
    JOIN customers c ON a.customer_id = c.customer_id
    JOIN branches  b ON a.branch_id   = b.branch_id
) flagged
WHERE FlagReason IS NOT NULL
ORDER BY transaction_date DESC;
GO




