# 🏦 Digital Session & Device Risk Profiling in Banking

> **A SQL-based fraud analytics project exploring how session risk signals, device trust status, and login geography relate to confirmed fraud outcomes in a simulated UK banking environment.**

---

## 📋 Project Overview

This project analyses digital session behaviour across a simulated UK banking customer base to profile the risk associated with login sessions. Using a structured banking dataset of **12,000 digital sessions** across **2,500+ customers**, the analysis examines session risk scores, failed login attempts, device trust status, and login geography — and investigates how these signals connect to confirmed fraud cases.

The project was completed using **SQL Server** for all data extraction and analysis, with results captured in Excel. It is designed as a portfolio piece for a Junior Data Analyst role, demonstrating practical skills in multi-table SQL querying, KPI calculation, and translating raw data into business-relevant findings.

---

## 🔍 Business Problem

UK banks face persistent fraud risk from compromised devices and logins originating from high-risk locations. Trusted-device programmes — where the bank maintains a list of verified, trusted customer devices — are a key fraud control mechanism. However, their effectiveness is **rarely quantified analytically**.

This project addresses a clear operational question: **do session-level signals (risk scores, failed logins, device trust, login geography) actually differentiate fraudulent from non-fraudulent customer behaviour?** And critically — **does the trusted-device programme measurably reduce fraud rates?**

---

## 🎯 Objectives

- Analyse session risk scores across the customer base to understand the distribution and scale of high-risk digital activity.
- Examine whether failed login attempts correlate with higher session risk scores.
- Compare confirmed fraud rates between customers using trusted versus untrusted devices.
- Measure the share of sessions originating from high-risk countries and assess whether they carry higher risk scores.
- Understand how fraud-relevant session risk is distributed across customer risk rating segments.

---

## ❓ Business Questions

| # | Business Question |
|---|---|
| 1 | What proportion of all digital sessions carry a high session risk score, and how does this vary by device type? |
| 2 | What is the distribution of failed login attempts across sessions, and do high failed-attempt sessions correspond to higher risk scores? |
| 3 | Do customers logging in from untrusted devices have a materially higher confirmed fraud rate than those using trusted devices? |
| 4 | What share of sessions originates from high-risk countries, and what is the average risk score for those sessions compared to low-risk countries? |
| 5 | Which customer risk rating segments generate the most high-risk sessions? |

---

## 🗄️ Dataset / Data Scope

This project uses a **simulated UK banking dataset** structured across two schemas (`Banking` and `Common`). No real customer data was used.

| Table | Schema | Role in Analysis |
|---|---|---|
| `FactDigitalSession` | Banking | Core fact table — session risk scores, failed attempts, login success, device & location references |
| `DimDevice` | Banking | Device trust status and device type |
| `DimLocation` | Banking | Country, city, and high-risk country flag |
| `DimAccount` | Banking | Links customers to accounts (bridge to transactions) |
| `FactTransaction` | Banking | Links accounts to transactions |
| `FactFraudAlert` | Banking | Links transactions to fraud alerts |
| `FactCase` | Banking | Confirmed fraud flag and financial loss amount |
| `Customer` | Common | Customer risk rating for segment analysis |

**Dataset size:**
- **12,000** digital sessions analysed
- **3,500** registered devices
- **2,500** customers
- **800** login locations across multiple countries
- **2,800** fraud cases in the system

---

## 📊 Key KPIs

| # | KPI | Definition | SQL Query |
|---|---|---|---|
| 1 | % High-Risk Sessions | Sessions where `SessionRiskScore ≥ 7` / Total Sessions × 100 | Q1, Q7 |
| 2 | Failed Login Rate | Sessions with `FailedAttemptsCount > 0` / Total Sessions × 100 | Q3 |
| 3 | Untrusted Device Fraud Rate | Customers with confirmed fraud on untrusted devices / all untrusted-device customers × 100 | Q8 |
| 4 | High-Risk Country Session Share | Sessions from `IsHighRiskCountry = 1` / Total Sessions × 100 | Q5 |
| 5 | Avg Session Risk Score by Device Trust | `AVG(SessionRiskScore)` grouped by `IsTrustedDevice` | Q6 |
| 6 | Total Confirmed Fraud Loss (Untrusted Device) | `SUM(LossAmount)` where `IsTrustedDevice = 0` and `FraudConfirmedFlag = 1` | Q8 |

---

## 🔑 Key Findings

All figures below are drawn directly from the SQL query results in the Excel results file.

---

### Finding 1 — Session Risk Distribution

**92.97% of all 12,000 sessions (11,156 sessions) were classified as high-risk**, using the project's `SessionRiskScore ≥ 7` threshold.

| Risk Band | Session Count | % of Total | Avg Risk Score |
|---|---|---|---|
| High Risk | 11,156 | 92.97% | 53.38 |
| Low Risk | 466 | 3.88% | 1.92 |
| Medium Risk | 378 | 3.15% | 5.49 |

> **Note:** The `SessionRiskScore` in this dataset operates on a **0–100 scale**. The threshold of ≥ 7 is therefore a relatively low bar, which explains why almost all sessions exceed it. The average risk score for flagged sessions (53.38) confirms meaningful signal exists, but the threshold would need recalibration in a real-world deployment to produce a more targeted flag rate.

---

### Finding 2 — Failed Login Rate

**83.46% of all sessions had at least one failed login attempt** — a notably high rate across the customer base.

| Failed Attempts | Sessions | Successful Logins | Failed Logins | Avg Risk Score |
|---|---|---|---|---|
| 0 | 1,985 | 1,803 | 182 | 50.50 |
| 1 | 2,015 | 1,850 | 165 | 50.35 |
| 2 | 2,006 | 1,835 | 171 | 48.89 |
| 3 | 1,994 | 1,838 | 156 | 49.56 |
| 4 | 1,996 | 1,833 | 163 | 49.84 |
| 5 | 2,004 | 1,837 | 167 | 50.09 |

> **Observed pattern:** Sessions are almost perfectly evenly distributed across all failed attempt counts (~2,000 per group), and average risk scores are virtually flat (range: **48.89–50.50**). In this dataset, the number of failed login attempts is **not a meaningful predictor** of session risk score on its own.

---

### Finding 3 — High-Risk Country Login Share

**11.3% of all sessions originated from high-risk countries** (Nigeria, Pakistan, UAE).

| Metric | Value |
|---|---|
| High-risk country session share | **11.30%** |
| Avg risk score — high-risk country sessions | 49.98 |
| Avg risk score — low-risk country sessions | 49.86 |
| Difference | 0.12 points |

> **Observed pattern:** The difference in average session risk scores between high-risk and low-risk country logins is negligible (0.12 points). While high-risk country logins should remain under monitoring, the session risk score alone does not clearly differentiate them from low-risk country sessions in this dataset.

The highest individual risk scores within high-risk countries came from:
- **UAE / Lake Jane**: Avg score 72.03 (19 sessions, 4 failed logins)
- **Pakistan / North Jordan**: Avg score 58.61 (21 sessions)
- **Nigeria / Elizabethfort**: Avg score 58.09 (22 sessions, 2 failed logins)

---

### Finding 4 — Device Type vs High-Risk Sessions

| Device Type | Total Sessions | High-Risk Sessions | % High-Risk |
|---|---|---|---|
| Laptop | 3,054 | 2,858 | **93.58%** |
| Desktop | 3,010 | 2,796 | 92.89% |
| Tablet | 3,050 | 2,828 | 92.72% |
| Mobile | 2,886 | 2,674 | **92.65%** |

> **Observed pattern:** The spread across device types is minimal — only a **0.93 percentage point** difference between the highest (Laptop 93.58%) and lowest (Mobile 92.65%). Device type alone is not a meaningful differentiator of session risk in this dataset.

---

### Finding 5 — Device Trust Status vs Confirmed Fraud Rate *(Most Significant Finding)*

| Device Trust | Unique Customers | Customers with Confirmed Fraud | Fraud Rate | Total Fraud Loss |
|---|---|---|---|---|
| Untrusted (0) | 1,904 | 504 | 26.47% | £18,712,346 |
| Trusted (1) | 2,410 | 647 | 26.85% | **£41,633,645** |

> **Key observation:** Trusted device customers had a **marginally higher confirmed fraud rate (26.85%) than untrusted device customers (26.47%)**. Total fraud losses associated with trusted device customers (£41.6M) were **more than double** those of untrusted device customers (£18.7M).
>
> This result challenges the assumption that device trust status alone reduces fraud exposure. The likely explanation is that the trusted customer group is larger (2,410 vs 1,904 customers) and may represent higher-value or more active accounts. This is an important finding for the trusted-device programme team: **trust status is not sufficient as a standalone fraud control**, and higher-value accounts within the trusted group may need additional monitoring layers.

---

### Finding 6 — High-Risk Sessions by Customer Risk Rating

| Customer Risk Rating | Total Sessions | High-Risk Sessions | % High-Risk |
|---|---|---|---|
| Low | 6,668 | 6,199 | 92.97% |
| Medium | 3,482 | 3,240 | **93.05%** |
| High | 1,850 | 1,717 | 92.81% |

> **Observed pattern:** The percentage of high-risk sessions is almost identical across all three customer risk rating segments (range: **92.81–93.05%**). "Low" risk-rated customers generate the highest **volume** of high-risk sessions (6,199) simply because they make up the largest part of the customer base. The session risk score threshold does not differentiate risk rating segments in this dataset.

---

## 💡 Business Insights

1. **The current session risk threshold needs recalibration.** With 92.97% of sessions flagged as high-risk, the ≥ 7 threshold on a 0–100 scale is too broad to be operationally useful for prioritisation. A higher threshold (e.g., ≥ 50 or ≥ 70) would produce a more targeted and actionable alert set.

2. **Failed login count alone is not a reliable fraud signal.** The flat relationship between failed attempt counts and average risk scores suggests that failed logins are common across the customer base and do not independently indicate elevated fraud risk. Fraud detection rules should combine failed logins with other signals (e.g., high-risk country + untrusted device).

3. **Device trust status does not clearly separate fraud outcomes.** The fraud rates for trusted (26.85%) and untrusted (26.47%) customers are nearly identical. This suggests the bank should audit whether the trusted-device programme is being applied consistently, or whether higher-value accounts within the trusted group need supplementary controls.

4. **High-risk country sessions require additional context.** The 11.3% share of sessions from high-risk countries (Nigeria, Pakistan, UAE) is meaningful from a regulatory monitoring perspective, but the near-identical risk scores between high-risk and low-risk country sessions suggest that country origin alone is not a strong predictor. Specific cities (e.g., UAE / Lake Jane with avg score 72.03) show elevated scores and may warrant closer review.

5. **Session risk is broadly distributed regardless of customer risk rating.** The bank's existing customer risk ratings (Low / Medium / High) do not appear to segment digital session risk in a meaningful way. This may indicate that the session risk score and customer risk rating are measuring different dimensions of risk that do not align in this dataset.

---

## 🛠️ Tools & Skills Demonstrated

| Category | Detail |
|---|---|
| **Database** | SQL Server (`Banking` and `Common` schema) |
| **SQL Techniques** | Multi-table `JOIN`s (up to 6 tables), `LEFT JOIN`, `CTE` (Common Table Expressions), `CASE WHEN`, `GROUP BY`, `ORDER BY`, aggregate functions (`COUNT`, `SUM`, `AVG`, `MAX`), window function (`SUM(COUNT()) OVER()`), `NULLIF`, `COALESCE`, `ROUND` |
| **Query Design** | Separated KPI summary queries from detailed breakdown queries; used CTEs to manage complex multi-hop joins cleanly |
| **Data Analysis** | KPI calculation, percentage shares, segment comparison, fraud rate analysis, cross-table join for outcome measurement |
| **Reporting** | Results structured and reported in Excel, findings summarised in plain-language business terms |
| **Domain Knowledge** | UK banking fraud controls, trusted-device programmes, session risk profiling, login geography risk |

---

## 🔄 Analysis Approach

The analysis followed a structured, query-by-query approach aligned to each business question:

1. **Session risk distribution** (Q1) — Classified all 12,000 sessions into risk bands using a `CASE WHEN` statement on `SessionRiskScore`, then calculated each band's percentage share using a window function.

2. **Failed login patterns** (Q2 + Q3) — First analysed the detailed pattern of how failed attempts distribute across sessions and their average risk scores; then calculated the overall failed login rate as a single KPI.

3. **Country risk analysis** (Q4 + Q5) — Joined the session table to the location dimension to produce both a city-level breakdown and an overall KPI for high-risk country session share and average risk score comparison.

4. **Device trust analysis** (Q6 + Q7) — Joined sessions to the device dimension to compare average risk scores, high-risk session counts, and failed attempts between trusted and untrusted devices, broken down by device type.

5. **Confirmed fraud rate by device trust** (Q8) — The most technically complex query: a CTE first aggregated confirmed fraud and loss at the customer level via a five-table join chain (`FactDigitalSession → DimDevice → DimAccount → FactTransaction → FactFraudAlert → FactCase`), then joined back to calculate fraud rates per device trust group. `LEFT JOIN` was used throughout to retain customers with no confirmed fraud, ensuring the denominator was correct.

6. **Customer risk segment analysis** (Q9) — Joined sessions to the `Common.Customer` table to compare high-risk session rates across customer risk rating segments.

---

## 💼 Project Outcome / Business Value

This project delivers a **clear, evidence-based view of digital session risk** across the customer base, grounded entirely in the available data. The key outputs for business stakeholders are:

- **For the Fraud Analytics Team:** The session risk score threshold requires recalibration — at ≥ 7 it captures 93% of all sessions and cannot be used for triage without adjustment. The analysis provides the distribution data needed to set a more effective threshold.

- **For the Digital Banking / Online Fraud Team:** Device trust status does not materially differentiate fraud rates in this dataset (26.47% vs 26.85%). The team should investigate whether the trusted-device programme is correctly scoped, and whether higher-value trusted accounts need additional authentication controls.

- **For Financial Crime Compliance:** 11.3% of sessions originate from high-risk countries (Nigeria, Pakistan, UAE), providing a measurable, reportable figure for regulatory monitoring purposes. The city-level breakdown (Q4) supports a targeted watchlist approach.

- **For the Risk Committee:** The confirmed fraud losses associated with trusted device customers (£41.6M) exceed those of untrusted customers (£18.7M), which may prompt a review of how device trust status is being communicated as a risk reduction metric.

---

## 📁 Project Files

| File | Description |
|---|---|
| `Digital Session & Device Risk Profiling.sql` | All 9 SQL queries used for the analysis, with inline comments explaining each query's purpose |
| `Digital Session & Device Risk Profiling.xlsx` | SQL query results exported to Excel — one tab per query result set |
| `Digital_Session_Device_Risk_Profiling.docx` | Full project documentation — business problem, objectives, KPIs, stakeholders, methodology, and business value |
| `README.md` | This file |

**SQL query index:**

| Query | Purpose | KPI / BQ Addressed |
|---|---|---|
| Q1 | Session risk band distribution | KPI 1 |
| Q2 | Failed login patterns vs risk score | BQ 2 |
| Q3 | Failed login rate (single KPI figure) | KPI 2 |
| Q4 | High-risk country session breakdown by city | BQ 4 |
| Q5 | High-risk country session share + avg risk comparison | KPI 4 |
| Q6 | Device trust vs avg session risk and failed attempts | KPI 5 |
| Q7 | % High-risk sessions by device type | BQ 1 |
| Q8 | Confirmed fraud rate and total loss by device trust (CTE) | KPI 3, KPI 6 |
| Q9 | High-risk sessions by customer risk rating segment | BQ 5 |

---

## ✅ Conclusion

This project demonstrates end-to-end SQL analytical skills applied to a realistic UK banking fraud analytics scenario — from business problem definition through to SQL query execution and business-oriented result interpretation.

The most significant findings challenge the assumptions underlying the project's starting hypothesis: **session risk signals in this dataset (failed logins, device trust, country risk) do not strongly differentiate fraud outcomes** using the current threshold settings. Rather than presenting this as a limitation, this is an honest and analytically valuable finding — in a real banking environment, it would trigger a threshold review, a deeper audit of the trusted-device programme, and a reassessment of how these signals are combined in fraud detection rules.

The project is intentionally kept at a **junior analyst scope**: focused, evidence-based, clearly documented, and free from unsupported claims. All findings in this README are drawn directly from the SQL query results.

---

*Dataset: Simulated UK banking data. No real customer information was used. Analysis completed using SQL Server.*  
*Analyst: Muhammad Danish | Junior Data Analyst*
