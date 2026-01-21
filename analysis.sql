-- Analisi CRM Sales Pipeline
-- Database: MySQL 8.0+


-- CONTROLLI INIZIALI E QUALITA DATI
-- Prima di analizzare, controllo cosa ho e se ci sono problemi evidenti

-- Conteggio righe per ogni tabella
SELECT 'accounts' AS tabella, COUNT(*) AS righe FROM accounts
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sales_teams', COUNT(*) FROM sales_teams
UNION ALL
SELECT 'sales_pipeline', COUNT(*) FROM sales_pipeline;

-- Controllo valori nulli nelle colonne principali di sales_pipeline
-- Mi interessa sapere quante opportunita non hanno account o date
SELECT
    COUNT(*) AS totale_opportunita,
    SUM(CASE WHEN account IS NULL OR account = '' THEN 1 ELSE 0 END) AS senza_account,
    SUM(CASE WHEN engage_date IS NULL THEN 1 ELSE 0 END) AS senza_engage_date,
    SUM(CASE WHEN close_date IS NULL THEN 1 ELSE 0 END) AS senza_close_date,
    SUM(CASE WHEN close_value IS NULL THEN 1 ELSE 0 END) AS senza_close_value
FROM sales_pipeline;

-- Quali sono i deal_stage presenti? Verifico che siano quelli attesi
SELECT deal_stage, COUNT(*) AS conteggio
FROM sales_pipeline
GROUP BY deal_stage
ORDER BY conteggio DESC;

-- Controllo se ci sono sales_agent in pipeline che non esistono in sales_teams
SELECT DISTINCT sp.sales_agent
FROM sales_pipeline sp
LEFT JOIN sales_teams st ON sp.sales_agent = st.sales_agent
WHERE st.sales_agent IS NULL;


-- OVERVIEW PIPELINE
-- Numeri generali per capire le dimensioni del business

-- Valore totale pipeline, numero opportunita, valore medio
SELECT
    COUNT(*) AS totale_opportunita,
    SUM(close_value) AS valore_totale,
    ROUND(AVG(close_value), 2) AS valore_medio,
    SUM(CASE WHEN deal_stage = 'Won' THEN close_value ELSE 0 END) AS valore_vinto
FROM sales_pipeline;

-- Range temporale dei dati
SELECT
    MIN(engage_date) AS prima_engage,
    MAX(engage_date) AS ultima_engage,
    MIN(close_date) AS prima_close,
    MAX(close_date) AS ultima_close
FROM sales_pipeline;


-- FUNNEL PER DEAL STAGE
-- Quante opportunita e quanto valore per ogni stage

SELECT
    deal_stage,
    COUNT(*) AS num_opportunita,
    SUM(close_value) AS valore_totale,
    ROUND(AVG(close_value), 2) AS valore_medio
FROM sales_pipeline
GROUP BY deal_stage
ORDER BY
    CASE deal_stage
        WHEN 'Prospecting' THEN 1
        WHEN 'Engaging' THEN 2
        WHEN 'Won' THEN 3
        WHEN 'Lost' THEN 4
    END;


-- WIN RATE E LOST RATE
-- Quanto chiudiamo? Su opportunita chiuse (Won + Lost)

-- Win rate complessivo
SELECT
    COUNT(*) AS deal_chiusi,
    SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) AS vinti,
    SUM(CASE WHEN deal_stage = 'Lost' THEN 1 ELSE 0 END) AS persi,
    ROUND(
        SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS win_rate_perc
FROM sales_pipeline
WHERE deal_stage IN ('Won', 'Lost');

-- Win rate per prodotto
-- Utile per capire quali prodotti si chiudono meglio
SELECT
    product,
    COUNT(*) AS deal_chiusi,
    SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) AS vinti,
    ROUND(
        SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS win_rate_perc
FROM sales_pipeline
WHERE deal_stage IN ('Won', 'Lost')
GROUP BY product
ORDER BY win_rate_perc DESC;


-- PERFORMANCE PER SALES REP E TEAM
-- Chi vende di piu? Chi converte meglio?

-- Performance per singolo venditore
SELECT
    sp.sales_agent,
    st.manager,
    st.regional_office,
    COUNT(*) AS totale_deal,
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS deal_vinti,
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS valore_vinto,
    ROUND(
        SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN sp.deal_stage IN ('Won', 'Lost') THEN 1 ELSE 0 END), 0),
        2
    ) AS win_rate_perc
FROM sales_pipeline sp
JOIN sales_teams st ON sp.sales_agent = st.sales_agent
GROUP BY sp.sales_agent, st.manager, st.regional_office
ORDER BY valore_vinto DESC;

-- Performance per regional office
SELECT
    st.regional_office,
    COUNT(*) AS totale_deal,
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS valore_vinto,
    ROUND(
        SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN sp.deal_stage IN ('Won', 'Lost') THEN 1 ELSE 0 END), 0),
        2
    ) AS win_rate_perc
FROM sales_pipeline sp
JOIN sales_teams st ON sp.sales_agent = st.sales_agent
GROUP BY st.regional_office
ORDER BY valore_vinto DESC;

-- Performance per manager
SELECT
    st.manager,
    COUNT(DISTINCT sp.sales_agent) AS num_venditori,
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS valore_vinto,
    ROUND(
        SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN sp.deal_stage IN ('Won', 'Lost') THEN 1 ELSE 0 END), 0),
        2
    ) AS win_rate_perc
FROM sales_pipeline sp
JOIN sales_teams st ON sp.sales_agent = st.sales_agent
GROUP BY st.manager
ORDER BY valore_vinto DESC;


-- TOP ACCOUNTS
-- Quali clienti generano piu valore?

-- Top 10 clienti per valore vinto
SELECT
    sp.account,
    a.sector,
    a.revenue AS fatturato_cliente_mln,
    COUNT(*) AS num_deal,
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS valore_vinto
FROM sales_pipeline sp
LEFT JOIN accounts a ON sp.account = a.account
WHERE sp.account IS NOT NULL AND sp.account != ''
GROUP BY sp.account, a.sector, a.revenue
ORDER BY valore_vinto DESC
LIMIT 10;

-- Concentrazione fatturato: quanto pesano i top 5 clienti sul totale?
WITH cliente_valore AS (
    SELECT
        account,
        SUM(CASE WHEN deal_stage = 'Won' THEN close_value ELSE 0 END) AS valore_vinto
    FROM sales_pipeline
    WHERE account IS NOT NULL AND account != ''
    GROUP BY account
),
totale AS (
    SELECT SUM(valore_vinto) AS valore_totale FROM cliente_valore
)
SELECT
    'Top 5 clienti' AS segmento,
    SUM(cv.valore_vinto) AS valore,
    ROUND(SUM(cv.valore_vinto) * 100.0 / t.valore_totale, 2) AS perc_sul_totale
FROM (
    SELECT valore_vinto FROM cliente_valore ORDER BY valore_vinto DESC LIMIT 5
) cv
CROSS JOIN totale t;


-- ANALISI PRODOTTI
-- Quali prodotti vendono di piu?

-- Performance per prodotto
SELECT
    sp.product,
    p.series,
    p.sales_price AS prezzo_listino,
    COUNT(*) AS num_deal,
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS deal_vinti,
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS valore_vinto,
    ROUND(AVG(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value END), 2) AS valore_medio_vinto
FROM sales_pipeline sp
LEFT JOIN products p ON sp.product = p.product
GROUP BY sp.product, p.series, p.sales_price
ORDER BY valore_vinto DESC;

-- Performance per serie prodotto
SELECT
    p.series,
    COUNT(*) AS num_deal,
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS valore_vinto,
    ROUND(
        SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN sp.deal_stage IN ('Won', 'Lost') THEN 1 ELSE 0 END), 0),
        2
    ) AS win_rate_perc
FROM sales_pipeline sp
LEFT JOIN products p ON sp.product = p.product
GROUP BY p.series
ORDER BY valore_vinto DESC;


-- ANALISI TEMPORALE
-- Andamento nel tempo

-- Deal chiusi per mese
SELECT
    DATE_FORMAT(close_date, '%Y-%m') AS mese,
    COUNT(*) AS deal_chiusi,
    SUM(CASE WHEN deal_stage = 'Won' THEN close_value ELSE 0 END) AS valore_vinto,
    SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) AS deal_vinti
FROM sales_pipeline
WHERE close_date IS NOT NULL
GROUP BY DATE_FORMAT(close_date, '%Y-%m')
ORDER BY mese;

-- Deal chiusi per trimestre
SELECT
    CONCAT(YEAR(close_date), '-Q', QUARTER(close_date)) AS trimestre,
    COUNT(*) AS deal_chiusi,
    SUM(CASE WHEN deal_stage = 'Won' THEN close_value ELSE 0 END) AS valore_vinto
FROM sales_pipeline
WHERE close_date IS NOT NULL
GROUP BY YEAR(close_date), QUARTER(close_date)
ORDER BY YEAR(close_date), QUARTER(close_date);

-- Nuove opportunita per mese (basato su engage_date)
SELECT
    DATE_FORMAT(engage_date, '%Y-%m') AS mese,
    COUNT(*) AS nuove_opportunita
FROM sales_pipeline
WHERE engage_date IS NOT NULL
GROUP BY DATE_FORMAT(engage_date, '%Y-%m')
ORDER BY mese;


-- DEAL VELOCITY
-- Quanto tempo ci vuole per chiudere un deal?

-- Tempo medio di chiusura (da engage a close)
SELECT
    ROUND(AVG(DATEDIFF(close_date, engage_date)), 1) AS giorni_medi_chiusura,
    MIN(DATEDIFF(close_date, engage_date)) AS min_giorni,
    MAX(DATEDIFF(close_date, engage_date)) AS max_giorni
FROM sales_pipeline
WHERE close_date IS NOT NULL AND engage_date IS NOT NULL;

-- Tempo medio per deal_stage finale
SELECT
    deal_stage,
    ROUND(AVG(DATEDIFF(close_date, engage_date)), 1) AS giorni_medi,
    COUNT(*) AS num_deal
FROM sales_pipeline
WHERE close_date IS NOT NULL AND engage_date IS NOT NULL
    AND deal_stage IN ('Won', 'Lost')
GROUP BY deal_stage;

-- Tempo medio di chiusura per prodotto
SELECT
    product,
    ROUND(AVG(DATEDIFF(close_date, engage_date)), 1) AS giorni_medi_chiusura,
    COUNT(*) AS deal_chiusi
FROM sales_pipeline
WHERE close_date IS NOT NULL AND engage_date IS NOT NULL
    AND deal_stage IN ('Won', 'Lost')
GROUP BY product
ORDER BY giorni_medi_chiusura;


-- OPPORTUNITA BLOCCATE / STAGNANTI
-- Deal aperti da troppo tempo, potrebbero servire azioni

-- Deal ancora in Prospecting o Engaging senza close_date
-- Calcolo quanti giorni sono passati da engage_date
SELECT
    opportunity_id,
    sales_agent,
    product,
    account,
    deal_stage,
    engage_date,
    DATEDIFF(CURDATE(), engage_date) AS giorni_aperti
FROM sales_pipeline
WHERE deal_stage IN ('Prospecting', 'Engaging')
    AND close_date IS NULL
    AND engage_date IS NOT NULL
    AND DATEDIFF(CURDATE(), engage_date) > 90
ORDER BY giorni_aperti DESC;

-- Conteggio deal aperti per fasce di tempo
SELECT
    CASE
        WHEN DATEDIFF(CURDATE(), engage_date) <= 30 THEN '0-30 giorni'
        WHEN DATEDIFF(CURDATE(), engage_date) <= 60 THEN '31-60 giorni'
        WHEN DATEDIFF(CURDATE(), engage_date) <= 90 THEN '61-90 giorni'
        ELSE 'oltre 90 giorni'
    END AS fascia_tempo,
    COUNT(*) AS num_deal
FROM sales_pipeline
WHERE deal_stage IN ('Prospecting', 'Engaging')
    AND close_date IS NULL
    AND engage_date IS NOT NULL
GROUP BY
    CASE
        WHEN DATEDIFF(CURDATE(), engage_date) <= 30 THEN '0-30 giorni'
        WHEN DATEDIFF(CURDATE(), engage_date) <= 60 THEN '31-60 giorni'
        WHEN DATEDIFF(CURDATE(), engage_date) <= 90 THEN '61-90 giorni'
        ELSE 'oltre 90 giorni'
    END
ORDER BY
    CASE fascia_tempo
        WHEN '0-30 giorni' THEN 1
        WHEN '31-60 giorni' THEN 2
        WHEN '61-90 giorni' THEN 3
        ELSE 4
    END;


-- SEGMENTAZIONI PER SETTORE E LOCALITA
-- Analisi per caratteristiche dei clienti

-- Performance per settore cliente
SELECT
    a.sector,
    COUNT(*) AS num_deal,
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS valore_vinto,
    ROUND(
        SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN sp.deal_stage IN ('Won', 'Lost') THEN 1 ELSE 0 END), 0),
        2
    ) AS win_rate_perc
FROM sales_pipeline sp
JOIN accounts a ON sp.account = a.account
GROUP BY a.sector
ORDER BY valore_vinto DESC;

-- Performance per localita cliente
SELECT
    a.office_location,
    COUNT(*) AS num_deal,
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS valore_vinto
FROM sales_pipeline sp
JOIN accounts a ON sp.account = a.account
GROUP BY a.office_location
ORDER BY valore_vinto DESC;

-- Deal con aziende subsidiary vs aziende indipendenti
SELECT
    CASE
        WHEN a.subsidiary_of IS NOT NULL AND a.subsidiary_of != '' THEN 'Subsidiary'
        ELSE 'Indipendente'
    END AS tipo_azienda,
    COUNT(*) AS num_deal,
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS valore_vinto
FROM sales_pipeline sp
JOIN accounts a ON sp.account = a.account
GROUP BY
    CASE
        WHEN a.subsidiary_of IS NOT NULL AND a.subsidiary_of != '' THEN 'Subsidiary'
        ELSE 'Indipendente'
    END;


-- ANALISI AGGIUNTIVE

-- Top performer per valore vinto (con ranking)
WITH venditori_ranked AS (
    SELECT
        sp.sales_agent,
        SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS valore_vinto,
        RANK() OVER (ORDER BY SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) DESC) AS ranking
    FROM sales_pipeline sp
    GROUP BY sp.sales_agent
)
SELECT * FROM venditori_ranked
WHERE ranking <= 10;

-- Combinazioni prodotto-settore piu redditizie
SELECT
    sp.product,
    a.sector,
    COUNT(*) AS num_deal,
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS valore_vinto
FROM sales_pipeline sp
JOIN accounts a ON sp.account = a.account
GROUP BY sp.product, a.sector
HAVING SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) > 0
ORDER BY valore_vinto DESC
LIMIT 15;

-- Valore medio deal per dimensione azienda cliente
SELECT
    CASE
        WHEN a.employees < 500 THEN 'Small (<500)'
        WHEN a.employees < 2000 THEN 'Medium (500-2000)'
        ELSE 'Large (>2000)'
    END AS dimensione_azienda,
    COUNT(*) AS num_deal,
    ROUND(AVG(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value END), 2) AS valore_medio_vinto
FROM sales_pipeline sp
JOIN accounts a ON sp.account = a.account
WHERE a.employees IS NOT NULL
GROUP BY
    CASE
        WHEN a.employees < 500 THEN 'Small (<500)'
        WHEN a.employees < 2000 THEN 'Medium (500-2000)'
        ELSE 'Large (>2000)'
    END
ORDER BY
    CASE dimensione_azienda
        WHEN 'Small (<500)' THEN 1
        WHEN 'Medium (500-2000)' THEN 2
        ELSE 3
    END;
