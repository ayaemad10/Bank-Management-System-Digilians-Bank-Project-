DROP DATABASE IF EXISTS Digilians_Bank;
CREATE DATABASE Digilians_Bank;
USE Digilians_Bank;

-- =========================
-- Branches
-- =========================
CREATE TABLE branches (
    branch_id    VARCHAR(20) PRIMARY KEY,
    branch_name  VARCHAR(100),
    manager_name VARCHAR(100),
    city         VARCHAR(50),
    country      VARCHAR(50)
);

-- =========================
-- Employees
-- =========================
CREATE TABLE employees (
    employee_id VARCHAR(20) PRIMARY KEY,
    first_name  VARCHAR(50),
    last_name   VARCHAR(50),
    role        VARCHAR(50),
    branch_id   VARCHAR(20),
    hire_date   DATE,
    CONSTRAINT fk_emp_branch
        FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);

-- =========================
-- Customers
-- =========================
CREATE TABLE customers (
    customer_id  VARCHAR(20) PRIMARY KEY,
    first_name   VARCHAR(50),
    last_name    VARCHAR(50),
    national_id  VARCHAR(20),
    phone        VARCHAR(20),
    email        VARCHAR(100),
    city         VARCHAR(50),
    credit_score INT,
    created_at   DATETIME,
    is_active    BIT DEFAULT 1,
    deleted_at   DATETIME NULL
);

-- =========================
-- Accounts
-- =========================
CREATE TABLE accounts (
    account_id   VARCHAR(20) PRIMARY KEY,
    customer_id  VARCHAR(20),
    branch_id    VARCHAR(20),
    account_type VARCHAR(20),
    balance_usd  DECIMAL(12,2),
    status       VARCHAR(20),
    open_date    DATE,
    is_active    BIT DEFAULT 1,
    closed_at    DATETIME NULL,
    CONSTRAINT fk_acc_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT fk_acc_branch
        FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);

-- =========================
-- Cards
-- =========================
CREATE TABLE cards (
    card_id         VARCHAR(20) PRIMARY KEY,
    account_id      VARCHAR(20),
    card_type       VARCHAR(20),
    expiration_date DATE,
    CONSTRAINT fk_card_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
        ON DELETE CASCADE      
        ON UPDATE CASCADE
);

-- =========================
-- Merchants
-- =========================
CREATE TABLE merchants (
    merchant_id   VARCHAR(20) PRIMARY KEY,
    merchant_name VARCHAR(100),
    city          VARCHAR(50)
);

-- =========================
-- Transactions
-- =========================
CREATE TABLE transactions (
    transaction_id   VARCHAR(25) PRIMARY KEY,
    account_id       VARCHAR(20),
    to_account_id    VARCHAR(20) NULL,
    merchant_id      VARCHAR(20) NULL,
    employee_id      VARCHAR(20) NULL,
    transaction_type VARCHAR(20) CHECK (transaction_type IN ('credit','debit','transfer')),
    amount_usd       DECIMAL(12,2),
    transaction_date DATETIME,
    description      VARCHAR(255),
    CONSTRAINT fk_txn_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT fk_txn_to_account
        FOREIGN KEY (to_account_id) REFERENCES accounts(account_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT fk_txn_merchant
        FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION,
    CONSTRAINT fk_txn_employee
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION
);
-- =========================
-- Loans
-- =========================
CREATE TABLE loans (
    loan_id       VARCHAR(20) PRIMARY KEY,
    customer_id   VARCHAR(20),
    loan_amount   DECIMAL(12,2),
    interest_rate DECIMAL(5,2),
    loan_status   VARCHAR(20),
    start_date    DATE,
    CONSTRAINT fk_loan_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE NO ACTION    
        ON UPDATE CASCADE
);

-- =========================
-- Loan Payments
-- =========================
CREATE TABLE loan_payments (
    payment_id   VARCHAR(20) PRIMARY KEY,
    loan_id      VARCHAR(20),
    amount_paid  DECIMAL(12,2),
    payment_date DATE,
    CONSTRAINT fk_loanpay_loan
        FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
        ON DELETE CASCADE      
        ON UPDATE CASCADE
);

-- =========================
-- Services
-- =========================
CREATE TABLE services (
    service_id   VARCHAR(20) PRIMARY KEY,
    service_name VARCHAR(50)
);

-- =========================
-- Customer Services
-- =========================
CREATE TABLE customer_services (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    customer_id VARCHAR(20),
    service_id  VARCHAR(20),
    employee_id VARCHAR(20) NULL,        
    status      VARCHAR(20),
    start_date  DATE,
    CONSTRAINT fk_cs_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT fk_cs_service
        FOREIGN KEY (service_id)  REFERENCES services(service_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT fk_cs_employee
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
        ON DELETE SET NULL         
        ON UPDATE CASCADE
);