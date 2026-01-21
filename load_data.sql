-- Caricamento dati CSV in MySQL
-- Database: MySQL 8.0+

-- ISTRUZIONI:
-- 1. Aprire MySQL Workbench o terminale MySQL
-- 2. Eseguire: CREATE DATABASE crm_sales;
-- 3. Eseguire: USE crm_sales;
-- 4. Eseguire schema.sql per creare le tabelle
-- 5. Modificare i path sotto con il percorso dei tuoi file CSV
-- 6. Eseguire questo file

-- Disabilito temporaneamente i controlli sulle foreign key
-- (necessario perche i dati nei CSV potrebbero non essere perfettamente allineati)
SET FOREIGN_KEY_CHECKS = 0;

-- Abilito il caricamento da file locali
SET GLOBAL local_infile = 1;

-- Path da modificare (sostituisci con il tuo percorso)
-- Esempio Windows: 'C:/Users/morga/OneDrive/Desktop/Tableau Portfolio Project/CRM_Sales_SQL_Analysis/accounts.csv'

-- Caricamento accounts
LOAD DATA LOCAL INFILE 'C:/Users/morga/OneDrive/Desktop/Tableau Portfolio Project/CRM_Sales_SQL_Analysis/accounts.csv'
INTO TABLE accounts
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(account, sector, year_established, revenue, employees, office_location, @subsidiary)
SET subsidiary_of = NULLIF(@subsidiary, '');

-- Caricamento products
LOAD DATA LOCAL INFILE 'C:/Users/morga/OneDrive/Desktop/Tableau Portfolio Project/CRM_Sales_SQL_Analysis/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(product, series, sales_price);

-- Caricamento sales_teams
LOAD DATA LOCAL INFILE 'C:/Users/morga/OneDrive/Desktop/Tableau Portfolio Project/CRM_Sales_SQL_Analysis/sales_teams.csv'
INTO TABLE sales_teams
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(sales_agent, manager, regional_office);

-- Caricamento sales_pipeline
LOAD DATA LOCAL INFILE 'C:/Users/morga/OneDrive/Desktop/Tableau Portfolio Project/CRM_Sales_SQL_Analysis/sales_pipeline.csv'
INTO TABLE sales_pipeline
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(opportunity_id, sales_agent, product, @account, deal_stage, @engage, @close, @value)
SET
    account = NULLIF(@account, ''),
    engage_date = NULLIF(@engage, ''),
    close_date = NULLIF(@close, ''),
    close_value = NULLIF(@value, '');

-- Riabilito i controlli sulle foreign key
SET FOREIGN_KEY_CHECKS = 1;

-- Verifica caricamento
SELECT 'accounts' AS tabella, COUNT(*) AS righe FROM accounts
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'sales_teams', COUNT(*) FROM sales_teams
UNION ALL SELECT 'sales_pipeline', COUNT(*) FROM sales_pipeline;
