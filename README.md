# CRM Sales Pipeline Analysis

A SQL project where I analyze a B2B sales CRM database to understand pipeline performance, sales team results, and customer patterns.

## About the project

 The data comes from a CRM with ~8,800 sales opportunities, and I focused on questions that a sales manager might actually ask: how's the pipeline doing, who are the top performers, which products sell best, where are deals getting stuck.

## Dataset

Four CSV files:

- **accounts.csv** - customer companies (sector, size, location)
- **products.csv** - product catalog with prices
- **sales_teams.csv** - sales reps and their managers
- **sales_pipeline.csv** - the actual deals with stages, dates, values

## Files in this repo

```
├── Dataset/           # CSV files
├── schema.sql         # database structure
├── load_data.sql      # script to import CSVs into MySQL
├── analysis.sql       # all the queries
├── report.md          # findings writeup (in Italian)
└── README.md
```

## How to run

1. Run `schema.sql` to create tables
2. Edit paths in `load_data.sql` and run it
3. Run queries from `analysis.sql`

I used MySQL 8.0 on Windows.

## What I analyzed

- Data quality (nulls, missing values)
- Pipeline totals and averages
- Win/loss rates overall and by product
- Sales rep performance and rankings
- Top accounts by revenue
- Deal velocity (how long to close)
- Stuck deals (open for 90+ days)
- Breakdown by sector and company size

## Some results

**Pipeline overview**

| opportunities | total_value | won_value |
|---------------|-------------|-----------|
| 8,800 | 10.5M | 9.4M |

**Win rate: ~60%** (4,238 won out of 7,021 closed deals)

**Top performers** - Darcel Schlecht leads with ~486k in won value, followed by Kary Hendrixson and Vicki Laflamme.

More details in `report.md`.

## What I learned

This was a good exercise in writing queries that answer real business questions, not just technical SQL practice. I also learned that data is never as clean as you expect - had to handle nulls and missing accounts in several queries.
