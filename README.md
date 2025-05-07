# Retail Analytics Project

## Overview

This project implements an end-to-end retail data analytics pipeline using modern data stack technologies. It processes online retail transaction data, performs data quality checks, and generates comprehensive business intelligence reports.

![Pipeline Overview](docs/images/dag_flow_overview.png)

## Tech Stack

- **Python** - Core programming language
- **Apache Airflow (Astronomer)** - Workflow orchestration
- **Google Cloud Platform**
  - Google Cloud Storage - Data lake
  - BigQuery - Data warehouse
- **dbt** - Data transformation & modeling
- **Soda** - Data quality checks
- **Metabase** - Data visualization
- **Docker & Docker Compose** - Containerization

## Project Structure

```
├── dags/                          # Airflow DAG definitions
│   └── retail.py                  # Main retail pipeline DAG
├── docs/                          # Documentation
│   └── images/                    # Project diagrams
├── include/
│   ├── datasets/                  # Source data files
│   │   ├── country.csv           # Country reference data
│   │   └── online_retail.csv     # Main retail data
│   ├── dbt/                      # dbt transformations
│   │   ├── models/
│   │   │   ├── report/          # Reporting models
│   │   │   ├── sources/         # Source definitions
│   │   │   └── transform/       # Core transformations
│   │   └── dbt_project.yml
│   └── soda/                     # Data quality checks
│       └── checks/               # Soda check definitions
└── docker-compose.override.yml    # Docker configuration
```

## Prerequisites

1. [Docker Desktop](https://docs.docker.com/desktop/)
2. [Astronomer CLI](https://www.astronomer.io/docs/cloud/stable/develop/cli-quickstart)
3. Google Cloud Platform account
4. Soda Cloud account
5. Python 3.8+

## Setup Instructions

### 1. Environment Setup

```bash
# Clone the repository
git clone <repository-url>
cd retail_analytics_project

# Initialize Astronomer project
astro dev init
```

### 2. GCP Configuration

1. Create a new GCP project at [console.cloud.google.com](https://console.cloud.google.com)
2. Enable required APIs:
   - BigQuery API
   - Cloud Storage API
3. Create a service account with the following roles:
   - BigQuery Admin
   - Storage Admin
4. Download service account key as `service_account.json`

### 3. Project Configuration

1. Create `include/gcp/` directory and place `service_account.json` there
2. Update configuration files:
   - `.env` - Environment variables
   - `include/dbt/profiles.yml` - dbt connection settings
   - `include/soda/configuration.yml` - Soda connection settings

### 4. Start the Pipeline

```bash
astro dev start
```

## Data Models

### Source Layer

- `raw_invoices` - Raw retail transaction data
- `raw_country` - Country reference data

### Transform Layer

1. Dimension Tables:

   - `dim_customer` - Customer information
   - `dim_datetime` - Date and time dimensions
   - `dim_product` - Product details

2. Fact Tables:
   - `fct_invoices` - Transaction fact table

### Report Layer

1. **Sales Overview** (`report_sales_overview.sql`)

   - Daily and country-level sales metrics
   - Revenue, transactions, and customer counts
   - Key indicators: total revenue, average transaction value

2. **Customer Analysis** (`report_customer_analysis.sql`)

   - Customer segmentation (Loyal/Regular/New)
   - Purchase patterns and behavior
   - Customer lifetime value metrics

3. **Product Performance** (`report_product_performance.sql`)

   - Product sales analysis
   - Revenue and quantity rankings
   - Geographic distribution

4. **Time Analysis** (`report_time_analysis.sql`)

   - Sales patterns by time period
   - Peak hours and seasonal trends
   - Year-over-year comparisons

5. **Geographic Analysis** (`report_geographic_analysis.sql`)
   - Country-level performance
   - Market penetration metrics
   - Regional product preferences

## Report Metrics Details

### Sales Metrics

```
Revenue = SUM(Quantity * UnitPrice)
Average Transaction Value = Revenue / COUNT(DISTINCT InvoiceNo)
Items per Transaction = SUM(Quantity) / COUNT(DISTINCT InvoiceNo)
```

### Customer Metrics

```
Customer Lifetime Value = SUM(Revenue) per CustomerID
Purchase Frequency = COUNT(DISTINCT InvoiceNo) / COUNT(DISTINCT CustomerID)
Average Days Between Purchases = AVG(days between customer purchases)
```

### Product Metrics

```
Product Revenue Share = Product Revenue / Total Revenue * 100
Stock Movement Rate = Quantity Sold / Time Period
Geographic Penetration = COUNT(DISTINCT Country) per Product
```

### Time-Based Metrics

```
Daily Sales Velocity = Revenue / Number of Active Hours
Peak Hour Performance = Revenue in Hour / Average Hourly Revenue
Seasonal Index = Period Revenue / Average Period Revenue
```

### Geographic Metrics

```
Market Share = Country Revenue / Total Revenue * 100
Customer Density = Customers per Country / Total Customers * 100
Product Diversity = Unique Products Sold per Country
```

## Data Quality Checks

### Source Checks

- Data completeness
- Data type validation
- Value range checks

### Transform Checks

- Referential integrity
- Business rule validation
- Metric consistency

### Report Checks

- Aggregation accuracy
- Time series continuity
- Cross-report consistency

## Using the Reports

### In dbt

```bash
# Run all models
dbt run

# Run specific report
dbt run --models report.report_sales_overview

# Run tests
dbt test
```

### In Metabase

1. Access: http://localhost:3000
2. Available Dashboards:
   - Sales Overview
   - Customer Insights
   - Product Analytics
   - Geographic Performance
   - Time Series Analysis

### Data Refresh Schedule

- Full refresh: Daily at 1 AM UTC
- Incremental updates: Every 6 hours
- Quality checks: After each data load

## Monitoring

### Airflow

- URL: http://localhost:8080
- Credentials: admin/admin
- DAG: retail_pipeline

### Soda Cloud

- Data quality monitoring
- Anomaly detection
- Alert configuration

### dbt Documentation

- Data lineage
- Table documentation
- Test coverage

## Troubleshooting

### Common Issues

1. Connection errors:

   - Verify GCP credentials
   - Check network connectivity
   - Validate service account permissions

2. Data quality failures:

   - Check Soda Cloud for detailed error messages
   - Verify source data integrity
   - Review transformation logic

3. Performance issues:
   - Monitor query performance in BigQuery
   - Check dbt model materialization
   - Review table partitioning

## Contact & Support

- GitHub: [Alan Lanceloth](https://github.com/alanceloth/)
- LinkedIn: [Alan Lanceloth](https://www.linkedin.com/in/alanlanceloth/)
- Email: [alan.lanceloth@gmail.com](mailto:alan.lanceloth@gmail.com)
- Project Repository: [Retail Analytics Project](https://github.com/alanceloth/Retail_Analytics_Project)
- YouTube Demo: [Live Project Demo](https://www.youtube.com/watch?v=NP08fHker5U)
