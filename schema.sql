-- CRM Sales Database Schema
-- Database: MySQL 8.0+

-- Creazione database (opzionale, decommentare se serve)
-- CREATE DATABASE IF NOT EXISTS crm_sales;
-- USE crm_sales;

-- Tabella: accounts
-- Contiene le aziende clienti
CREATE TABLE accounts (
    account VARCHAR(100) PRIMARY KEY,
    sector VARCHAR(50),
    year_established INT,
    revenue DECIMAL(10, 2),
    employees INT,
    office_location VARCHAR(100),
    subsidiary_of VARCHAR(100),

    INDEX idx_sector (sector),
    INDEX idx_office_location (office_location)
);

-- Tabella: products
-- Catalogo prodotti
CREATE TABLE products (
    product VARCHAR(50) PRIMARY KEY,
    series VARCHAR(20),
    sales_price DECIMAL(10, 2),

    INDEX idx_series (series)
);

-- Tabella: sales_teams
-- Sales agent e loro manager/uffici regionali
CREATE TABLE sales_teams (
    sales_agent VARCHAR(100) PRIMARY KEY,
    manager VARCHAR(100),
    regional_office VARCHAR(50),

    INDEX idx_manager (manager),
    INDEX idx_regional_office (regional_office)
);

-- Tabella: sales_pipeline
-- Opportunita commerciali (il cuore del CRM)
CREATE TABLE sales_pipeline (
    opportunity_id VARCHAR(20) PRIMARY KEY,
    sales_agent VARCHAR(100),
    product VARCHAR(50),
    account VARCHAR(100),
    deal_stage VARCHAR(20),
    engage_date DATE,
    close_date DATE,
    close_value DECIMAL(12, 2),

    INDEX idx_deal_stage (deal_stage),
    INDEX idx_engage_date (engage_date),
    INDEX idx_close_date (close_date),
    INDEX idx_sales_agent (sales_agent),

    FOREIGN KEY (sales_agent) REFERENCES sales_teams(sales_agent),
    FOREIGN KEY (product) REFERENCES products(product),
    FOREIGN KEY (account) REFERENCES accounts(account)
);
