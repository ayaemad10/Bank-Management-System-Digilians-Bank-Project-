USE Digilians_Bank;


-- ===================== 1. BRANCHES =====================
DECLARE @i INT = 1
WHILE @i <= 500
BEGIN
    INSERT INTO branches VALUES(
        'BR' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        'Branch_'  + CAST(@i AS VARCHAR),
        'Manager_' + CAST(@i AS VARCHAR),
        CASE WHEN @i%4=0 THEN 'Cairo'
             WHEN @i%4=1 THEN 'Dubai'
             WHEN @i%4=2 THEN 'London'
             ELSE 'Berlin' END,
        CASE WHEN @i%2=0 THEN 'Egypt' ELSE 'UAE' END
    )
    SET @i = @i + 1
END
GO

-- ===================== 2. CUSTOMERS =====================
DECLARE @i INT = 1
WHILE @i <= 500
BEGIN
    INSERT INTO customers VALUES(
        'CU' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        'First_'  + CAST(@i AS VARCHAR),
        'Last_'   + CAST(@i AS VARCHAR),
        '2980'    + RIGHT('0000' + CAST(@i AS VARCHAR), 4),
        '+2010'   + RIGHT('0000000' + CAST(@i AS VARCHAR), 8),
        'user'    + CAST(@i AS VARCHAR) + '@mail.com',
        CASE WHEN @i%4=0 THEN 'Cairo'
             WHEN @i%4=1 THEN 'Dubai'
             WHEN @i%4=2 THEN 'London'
             ELSE 'Paris' END,
        600 + (@i % 200),
        DATEADD(DAY, -@i, GETDATE()),
        1,
        NULL
    )
    SET @i = @i + 1
END
GO

-- ===================== 3. MERCHANTS =====================
DECLARE @i INT = 1
WHILE @i <= 500
BEGIN
    INSERT INTO merchants VALUES(
        'ME' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        'Merchant_' + CAST(@i AS VARCHAR),
        CASE WHEN @i%4=0 THEN 'Cairo'
             WHEN @i%4=1 THEN 'Dubai'
             WHEN @i%4=2 THEN 'London'
             ELSE 'Berlin' END
    )
    SET @i = @i + 1
END
GO

-- ===================== 4. SERVICES =====================
DECLARE @i INT = 1
WHILE @i <= 500
BEGIN
    INSERT INTO services VALUES(
        'SE' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        'Service_' + CAST(@i AS VARCHAR)
    )
    SET @i = @i + 1
END
GO

-- ===================== 5. EMPLOYEES =====================
DECLARE @i INT = 1
WHILE @i <= 500
BEGIN
    INSERT INTO employees(
        employee_id, first_name, last_name,
        role, branch_id, hire_date
    )
    VALUES(
        'EM' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        'EmpFirst_' + CAST(@i AS VARCHAR),
        'EmpLast_'  + CAST(@i AS VARCHAR),
        CASE WHEN @i%3=0 THEN 'Manager'
             WHEN @i%3=1 THEN 'Teller'
             ELSE 'Advisor' END,
        'BR' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        DATEADD(DAY, -@i*5, GETDATE())
    )
    SET @i = @i + 1
END
GO

-- ===================== 6. ACCOUNTS =====================
DECLARE @i INT = 1
WHILE @i <= 500
BEGIN
    INSERT INTO accounts(
        account_id, customer_id, branch_id,
        account_type, balance_usd, status,
        open_date, is_active, closed_at
    )
    VALUES(
        'AC' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        'CU' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        'BR' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        CASE WHEN @i%2=0 THEN 'checking' ELSE 'savings' END,
        1000 + (@i * 50),
        CASE WHEN @i%10=0 THEN 'inactive'
             WHEN @i%15=0 THEN 'closed'
             ELSE 'active' END,
        DATEADD(DAY, -@i*3, GETDATE()),
        CASE WHEN @i%10=0 OR @i%15=0 THEN 0 ELSE 1 END,
        CASE WHEN @i%15=0 THEN DATEADD(DAY, -@i, GETDATE()) ELSE NULL END
    )
    SET @i = @i + 1
END
GO

-- ===================== 7. CARDS =====================
DECLARE @i INT = 1
WHILE @i <= 500
BEGIN
    INSERT INTO cards VALUES(
        'CA' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        'AC' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        CASE WHEN @i%2=0 THEN 'debit' ELSE 'credit' END,
        DATEADD(YEAR, 3, GETDATE())
    )
    SET @i = @i + 1
END
GO

-- ===================== 8. LOANS =====================
DECLARE @i INT = 1
WHILE @i <= 500
BEGIN
    INSERT INTO loans VALUES(
        'LN' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        'CU' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        5000  + (@i * 100),
        5     + (@i % 5),
        CASE WHEN @i%3=0 THEN 'approved'
             WHEN @i%3=1 THEN 'pending'
             ELSE 'rejected' END,
        DATEADD(DAY, -@i*10, GETDATE())
    )
    SET @i = @i + 1
END
GO

-- ===================== 9. LOAN PAYMENTS =====================
DECLARE @i INT = 1
WHILE @i <= 500
BEGIN
    INSERT INTO loan_payments VALUES(
        'LP' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        'LN' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        200  + (@i * 10),
        DATEADD(DAY, -@i*5, GETDATE())
    )
    SET @i = @i + 1
END
GO

-- ===================== 10. TRANSACTIONS =====================
DECLARE @i INT = 1
WHILE @i <= 500
BEGIN
    INSERT INTO transactions(
        transaction_id, account_id, to_account_id,
        merchant_id, employee_id,
        transaction_type, amount_usd,
        transaction_date, description
    )
    VALUES(
        'TR' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        'AC' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        CASE WHEN @i%3=2
             THEN 'AC' + RIGHT('000' + CAST((@i%499)+1 AS VARCHAR), 3)
             ELSE NULL END,
        'ME' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        'EM' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        CASE WHEN @i%3=0 THEN 'credit'
             WHEN @i%3=1 THEN 'debit'
             ELSE 'transfer' END,
        CASE
            WHEN @i >= 490
                THEN 50000 + (@i * 1000)         
            WHEN @i%5=0 AND @i%3=1
                THEN (1000 + (@i * 50)) * 0.85   
            ELSE
                50 + (@i * 10)                  
        END,
        DATEADD(DAY, -(@i % 365), GETDATE()),    
        'Transaction_' + CAST(@i AS VARCHAR)
    )
    SET @i = @i + 1
END
GO

-- ===================== 11. CUSTOMER SERVICES — Round 1 =====================
DECLARE @i INT = 1
DECLARE @emp_id VARCHAR(20)

WHILE @i <= 500
BEGIN
    -- هنجيب أول موظف يقابلنا في الجدول عشان نضمن إنه موجود
    SELECT TOP 1 @emp_id = employee_id FROM employees ORDER BY NEWID() 

    INSERT INTO customer_services(customer_id, service_id, employee_id, status, start_date)
    VALUES(
        'CU' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        'SE' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        @emp_id,
        CASE WHEN @i % 2 = 0 THEN 'active' ELSE 'inactive' END,
        DATEADD(DAY, -@i * 2, GETDATE())
    )
    SET @i = @i + 1
END
GO

-- ===================== 12. CUSTOMER SERVICES — Round 2 =====================
DECLARE @i INT = 1
DECLARE @emp_id VARCHAR(20)

WHILE @i <= 500
BEGIN
    SELECT TOP 1 @emp_id = employee_id FROM employees ORDER BY NEWID() 

    INSERT INTO customer_services(customer_id, service_id, employee_id, status, start_date)
    VALUES(
        'CU' + RIGHT('000' + CAST(@i AS VARCHAR), 3),
        'SE' + RIGHT('000' + CAST(((@i + 249) % 500) + 1 AS VARCHAR), 3),
        @emp_id,
        'active',
        DATEADD(DAY, -@i, GETDATE())
    )
    SET @i = @i + 1
END
GO