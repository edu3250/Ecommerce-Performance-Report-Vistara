<div align="center">

<img src="assets/logo.svg" alt="VISTARA — Premium Fashion · Mexico" width="380"/>

<br/><br/>

# Ecommerce Performance Report 
<table align="center">
    <tr>
      <td width="1470">
        <h2 align="center">Client Background</h2>
        <body>
          <strong>VISTARA</strong> is a Mexican premium fashion e-commerce brand specializing in curated apparel and accessories for the contemporary Latin American consumer.
            Founded with a focus on quality craftsmanship and digital-first retail, VISTARA has grown its online presence across Mexico by combining editorial aesthetics with data-driven customer experiences. <br>
            <br> 
            With a registered customer base of over 10,000 buyers and more than 219,000 transactions processed throughout 2024, the brand operates at a scale where customer behavior patterns become both measurable and 
            strategically actionable. <br>
            <br>
            This report covers the full 2024 fiscal year (January – December), with January 1, 2025 set as the RFM reference anchor. The analysis was commissioned to support VISTARA's growth strategy heading into 2025 —
            identifying where revenue is being generated, which customers are at risk of churning, and where the highest-value acquisition cohorts are coming from. <br>
            <br>
        <body>
        <h3>Northstar metrics for this analysis:</h3>
        <h4>
            <ul><li>📈 Monthly net revenue trend and MoM growth</li>
                <li>🎯 RFM customer segmentation (Recency · Frequency · Monetary)</li>
                <li>🔄 Churn risk classification and retention rate</li>
                <li>👥 Cohort retention — tracking customer lifetime month by month </li>
            <ul>
        </h4>
        </td>
  </tr>
</table>
<table align="center">
  <tr>
    <div width="920">   
      <h1 align="center">Executive Summary</h1>
      <h3 align="center">BI Dashboard (2024 Period)</h3>
      <div align="center">
        <img width="1427" height="807" alt="image" src="https://github.com/user-attachments/assets/024bd784-b952-4a17-a8d4-935f01f3769c" />
      </div>
      <td width="460" valign="top">
        <ol>
          <li>
            <strong>Revenue Growth and Peak Performance:</strong>
            <ul>
              <li>Q4 2024 was the strongest period, with december recording the highest montlhy revenue of the year at approximately $44M.</li>
              <li>Q1 saw the highest volume of new customer acquisition. Revenue grew progressively through the year as repeat purchases accumulated, particularly among Champions and Loyal customers.</li>
              <li>ssss</li>
            </ul>
          </li>
          <li>
            <strong>Where Revenue Comes From</strong>
            <ul>
              <li>A small group of customers. 20% of the customers (champions) generate 76% of total revenue.The remaining customer base contributes meaningfully in Q1 and Q2 but shows
                  declining activity through the second half of the year.</li>
              <li>ssss.</li>
            </ul>
          </li>
        </ol>
      </td>
      <td width="460" valign="top">
        <ol start="3">
          <li>
            <strong>Quarterly Insights & Seasonal Trends</strong>
            <ul>
              <li>Q3 and Q4 of each year typically show strong performance, likely due to seasonal shopping trends and marketing efforts.</li>
              <li>Q1 2022 started well ($704K in January), but revenue quickly dropped, signaling an overall weak performance compared to previous years.</li>
            </ul>
          </li>
          <li>
            <strong>Key Takeaways & Recommendations</strong>
            <ul>
              <li>Investigate the causes of the 2022 decline (e.g., market changes, competition, internal factors).</li>
              <li>Leverage high-performing periods (e.g., Q3 and Q4 of strong years) to refine marketing and sales strategies.</li>
              <li>Reassess business strategy for 2023, focusing on pricing, promotions, and customer engagement to regain momentum.</li>
            </ul>
          </li>
        </ol>
      </td>
    </div>
  </tr>
</table>

<h2 align="center">Dataset Structure and ERD (Entity relationship diagram)</h2>
<body>The database structure as seen below consists of eight tables: orders, customers, products, dates, order details, returns, inventory and receipts with a total row count of 10,000 records.</body>
<div align="center">
  <img src="assets/erd.svg" alt="Vistara ERD Diagram · Mexico" width="900"/>
</div>

<h1 align="center">Insights Deep-Dive</h1>
<table align="center">
  <tr>
    <h1 align="center">Sales Trend</h1>
    <td width="1000">
      <img width="400" height="285" alt="image" src="https://github.com/user-attachments/assets/a8c7fca2-7b28-42bd-bb44-f0600e32c325" />
    </td>
    <td width="1000">
      <img width="400" height="283" alt="image" src="https://github.com/user-attachments/assets/c112a10e-79a8-419e-a9fd-6e323df6ff6d" />
    </td>
    <td width="1000">
      <img width="400" height="281" alt="image" src="https://github.com/user-attachments/assets/09893477-c7e9-44ca-a6ef-846e3bf09cda" />
    </td>
  </tr>
</table>

<table>
  <tr>
    <td>
      <strong>Sales Revenue</strong>
      <ol>
        <li>December Peak — Q4 Concentration Defines the Annual Revenue Profile <ul>
            <li>December recorded the highest monthly revenue of the year (~$44M). </li>
            <li>Confirming Q4 as the primary revenue driver. This concentration reflects the Champions segment's sustained activity through December, a tier that carries 
                a 50x purchase weight relative to baseline buyers. </li>
          </ul>
        </li>
        <li>Mid-Year Stability Masks a Structural Shift <ul>
            <li>From February through October, monthly revenue holds relatively stable in the $30–34M range. As lower-value tiers exit their active purchase windows the total order 
                count declines while per-order value rises. Revenue remains stable not because of consistent volume, but because higher-value segments progressively absorb a larger 
                share of transactions. </li>
            <li>2021 Slight Slowdown: Sales remained high but started stabilizing, showing a decline from peak pandemic levels.</li>
            <li>2022 Major Decline: A <strong>consistent drop in sales across all quarters</strong> suggests a post-pandemic correction, with inflation, lower consumer spending, or increased competition. </li>
          </ul>
        </li>
        <li>Declining Growth Throughout 2022 – Indicating Weak Consumer Demand <ul>
            <li>Each quarter in 2022 experienced a downward trend.</li>
            <li>Q1: Started fairly strong ($704K in Jan) but lower than 2021.</li>
            <li>Q2 - Q3: Dropped further, below $500K per month and continued decline through Q3 with Aug/Sep below $400K.</li>
            <li>Q4: <strong>Historic low, indicating critical demand issues</strong>. This suggests customer retention, pricing, or product-market fit issues. TechSphere may need to re-strategize through marketing, promotions, or change in pricing. </li>
          </ul>
        </li>
      </ol>
      <strong>Average Order Value</strong>
      <ol>
        <li> Sharp AOV Surge in 2020, followed by a Decline in 2021-2022 <ul>
            <li>
              <strong>2020 saw the highest AOV growth, peaking at $322 (Oct 2020)</strong> compared to $246 (Nov 2019), aligning with pandemic-driven eCommerce boom.
            </li>
            <li>Post-pandemic correction (2021-2022) led to a steady decline, with AOV in 2022 returning close to 2019 levels (~$234-$237).</li>
          </ul>
        </li>
        <li>2022 AOV is lower and relatively more volatile compared to previous years <ul>
            <li>
              <strong>2022 AOV fluctuates significantly </strong> between $216 (Oct) and $256 (Sep).
            </li>
            <li>Q4 2022 AOV is significantly lower than Q4 2020 & 2021, meaning holiday spending per order has dropped.</li>
          </ul>
        </li>
        <li>Long-Term AOV Decline May Indicate Price Sensitivity <ul>
            <li>From a peak of ~$322 in 2020, AOV steadily dropped to ~$234 in 2022 which is 27% drop.</li>
            <li>Over the span of four years, the change in AOV growth has been relatively constant, indicating minimal changes in product pricing (as illustrated in Sales Growth vs. AOV Growth below).</li>
            <li>AOV in 2022 is likely not a major factor in the decline of sales that year.</li>
          </ul>
        </li>
      </ol>
      <strong>Order Count</strong>
      <ol>
        <li>Order counts closely follow sales revenue, indicating that the decline in revenue is primarily due to <strong>fewer orders</strong> rather than a drop in AOV in 2022. </li>
        <li>Total orders <strong>dropped by 38%</strong> from 2021 to 2022. </li>
        <li>The sales anamoly and decline <strong>started in mid-2022</strong>, with orders falling from 2,034 in July to just 825 in October. </li>
        <li>While people are spending slightly less per order, the <strong>decline in order frequency</strong> directly results in lower sales revenue. </li>
      </ol>
    </td>
  </tr>
</table>

<img src="assets/product_performance.svg" alt="performance by product (2024)" width="1000"/>

<table aign="center">
  <tr>
      <td width="333" valign="top">
      <h3>The Best and Worst</h3>
      <ul>
        <li>Winter Wear led annual revenue at $123.4M MXN the top category consistently across all 12 months.</li>
        <li>Formal Wear is the second-best at $119.8M MXN (30.5%), separated from Winter Wear by only $3.6M.</li>
        <li>Beachwear is the lowest-revenue category at $22.0M MXN (5.6%) — unlike typical seasonality expectations, it peaks in December .</li>
      </ul>
      </td>
  <td width="333" valign="top">
      <h3>AOV Over Time</h3>
      <ul>
        <li>December AOV is the highest month of the year — holiday gifting and premium seasonal fashion drive larger average tickets across all customer tiers.</li>
        <li>El Buen Fin creates a visible AOV dip. Total November revenue still exceeds October because volume growth outweighs the AOV decline. </li>
        <li>A secondary May AOV uptick is visible across categories, driven by Día de las Madres .</li>
        <li>Winter Wear and Formal Wear are the primary AOV drivers — their premium price points keep the overall average elevated relative to Casual Wear (
            $75.7M on higher volume) and Beachwear ($22.0M at the lowest price tier).</li>
      </ul>
      </td>
      <td width="333" valign="top">
      <h3>Seasonal Findings</h3>
      <ul>
        <li>December dominates across all five categories. The holiday and year-end gifting season is the single most impactful revenue event.</li>
        <li>February is the universal low point across all categories, reflecting post-holiday demand contraction. No category is an exception.</li>
        <li>November shows a dual signal: AOV contracts (El Buen Fin discounts) while total revenue rises (volume surge). Winter Wear reaches $10.9M and Formal Wear $10.6M — both above their monthly average.</li>
      </ul>
      </td>
</tr>
</table>
<table align="center">
    <tr align="center">
      <td width="1000" valign="top">
      <h3>AOV Over Time (2019-2022)</h3>
      <img width="450" src="https://res.cloudinary.com/dxctpvd8v/image/upload/v1740156855/AOV_Products_BarGraph_CamilingJS">
    </td>
    <td width="1000">
      <h3>Product Sales Heat Map by Quarter</h3>
      <img width="450" src="https://res.cloudinary.com/dxctpvd8v/image/upload/v1740646006/Sales_Heatmap_CamilingJS">
    </td>
  </tr>
</table>
</table>

## Cohort Analysis
<div align="center">
  <img src="assets/cohort_heatmap.svg" alt="Cohort Retention Heatmap VISTARA 2024" width="100%">
</div>
<table>
  <tr>
    <td>
      <strong>Cohort Analysis</strong>
      <ol>
        <li>Good opening <ul>
            <li>During the opening month, 4,382 new customers were registered, with a solid retention rate of 58–64% over the first six months; 
            in the subsequent period, the retention rate dropped to 35% over the course of six months. From the third quarter onwards, 
            the acquisition of new customers came to a complete halt, with only 12 to 38 new customers per month.</li>
          </ul>
        </li>
        <li>Mid-Year Stability Masks a Structural Shift <ul>
            <li>From February through October, monthly revenue holds relatively stable in the $30–34M range. As lower-value tiers exit their active purchase windows the total order 
                count declines while per-order value rises. Revenue remains stable not because of consistent volume, but because higher-value segments progressively absorb a larger 
                share of transactions. </li>
            <li>2021 Slight Slowdown: Sales remained high but started stabilizing, showing a decline from peak pandemic levels.</li>
            <li>2022 Major Decline: A <strong>consistent drop in sales across all quarters</strong> suggests a post-pandemic correction, with inflation, lower consumer spending, or increased competition. </li>
          </ul>
        </li>
        <li>Declining Growth Throughout 2022 – Indicating Weak Consumer Demand <ul>
            <li>Each quarter in 2022 experienced a downward trend.</li>
            <li>Q1: Started fairly strong ($704K in Jan) but lower than 2021.</li>
            <li>Q2 - Q3: Dropped further, below $500K per month and continued decline through Q3 with Aug/Sep below $400K.</li>
            <li>Q4: <strong>Historic low, indicating critical demand issues</strong>. This suggests customer retention, pricing, or product-market fit issues. TechSphere may need to re-strategize through marketing, promotions, or change in pricing. </li>
          </ul>
        </li>
      </ol>
      <strong>Average Order Value</strong>
      <ol>
        <li> Sharp AOV Surge in 2020, followed by a Decline in 2021-2022 <ul>
            <li>
              <strong>2020 saw the highest AOV growth, peaking at $322 (Oct 2020)</strong> compared to $246 (Nov 2019), aligning with pandemic-driven eCommerce boom.
            </li>
            <li>Post-pandemic correction (2021-2022) led to a steady decline, with AOV in 2022 returning close to 2019 levels (~$234-$237).</li>
          </ul>
        </li>
        <li>2022 AOV is lower and relatively more volatile compared to previous years <ul>
            <li>
              <strong>2022 AOV fluctuates significantly </strong> between $216 (Oct) and $256 (Sep).
            </li>
            <li>Q4 2022 AOV is significantly lower than Q4 2020 & 2021, meaning holiday spending per order has dropped.</li>
          </ul>
        </li>
        <li>Long-Term AOV Decline May Indicate Price Sensitivity <ul>
            <li>From a peak of ~$322 in 2020, AOV steadily dropped to ~$234 in 2022 which is 27% drop.</li>
            <li>Over the span of four years, the change in AOV growth has been relatively constant, indicating minimal changes in product pricing (as illustrated in Sales Growth vs. AOV Growth below).</li>
            <li>AOV in 2022 is likely not a major factor in the decline of sales that year.</li>
          </ul>
        </li>
      </ol>
      <strong>Order Count</strong>
      <ol>
        <li>Order counts closely follow sales revenue, indicating that the decline in revenue is primarily due to <strong>fewer orders</strong> rather than a drop in AOV in 2022. </li>
        <li>Total orders <strong>dropped by 38%</strong> from 2021 to 2022. </li>
        <li>The sales anamoly and decline <strong>started in mid-2022</strong>, with orders falling from 2,034 in July to just 825 in October. </li>
        <li>While people are spending slightly less per order, the <strong>decline in order frequency</strong> directly results in lower sales revenue. </li>
      </ol>
    </td>
  </tr>
</table>

## Executive Summary

<div align="center">

*Page 1 — Executive KPIs Dashboard*

</div>

| KPI | Value | Trend |
|-----|-------|-------|
| Total Net Revenue (1Y) | ~$1.72M / month avg | ▲ Peaks in Q1 and Q4 |
| MoM Revenue Growth | Tracked dynamically | Compared to prior month |
| Avg Spend per Customer | Calculated by period | Period-filtered |
| Churn Rate | Dynamic by period | Inverted indicator (↓ = good) |
| Total Registered Customers | 10,000 | Stable base |

**Key executive findings:**

1. **Revenue is driven by a small champion segment.** The top 5% of customers (Champions tier) generate disproportionate revenue — consistent with the Pareto distribution used in data generation and confirmed by the RFM treemap.

2. **Loyal Customers peak at 15–25 months of tenure.** Beyond that window, engagement and average spend drop significantly — signaling a retention risk window that is actionable.

3. **Champions grow in value with tenure.** Unlike other segments, Champions' average spend increases continuously up to 75 months of relationship — making long-term retention the highest-ROI strategy.

4. **Cohort retention decays rapidly after Month 1.** January cohort retains ~59% in Month 1, dropping to ~36% by Month 3 — typical for premium fashion e-commerce, but improvement is feasible through loyalty incentives.

---

## Dataset Structure & ERD

The database was generated entirely in Python using a Pareto-weighted behavioral model and loaded into PostgreSQL under the `vistara` schema.

```
vistara_db
└── schema: vistara
    ├── dim_customers         — 10,000 customers with tier assignment
    ├── dim_products          — product catalog with categories
    ├── dim_sales_outlet      — store locations
    ├── dim_dates             — full date dimension
    ├── fact_sales_receipts   — ~219K transactions
    ├── fact_order_details    — line-level detail (price, qty, discount)
    ├── fact_returns          — ~1,572 returns (~0.72% return rate)
    └── fact_inventory        — stock records
```

**Customer tier distribution (Pareto weights):**

| Tier | % of Customers | Purchase Weight | Active Until |
|------|---------------|----------------|-------------|
| Champions | 5% | 50x | December |
| Loyal | 15% | 15x | October |
| Regular | 25% | 5x | July |
| Occasional | 30% | 2x | April |
| One-time | 25% | 0.5x | February |

> The Pareto weighting ensures realistic purchase frequency variance: min 1 order, median 7, max 129 per customer.

---

## Analytical SQL Views

Five analytical views are built on top of the fact tables, forming the data layer consumed by Power BI.

```
fact_sales_receipts + fact_order_details + fact_returns
        │
        ├──► v_rfm_base          ← raw R/F/M values per customer
        │         │
        │    v_rfm_scores        ← NTILE(5) scores per dimension
        │         │
        │    v_rfm_segments      ← named segments (Champions, At Risk…)
        │
        ├──► v_churn_analysis    ← Active / At Risk / Churned
        │
        ├──► v_monthly_revenue   ← monthly net revenue summary
        │
        ├──► v_monthly_retention ← retained vs. new customers per month
        │
        └──► v_cohort_retention  ← cohort matrix (M0, M1, M2… retention %)
```

**RFM scoring logic (NTILE-based):**

```sql
recency_score   = 6 - NTILE(5) OVER (ORDER BY days_since_last_purchase ASC)
frequency_score = NTILE(5) OVER (ORDER BY total_orders ASC)
monetary_score  = NTILE(5) OVER (ORDER BY net_spend ASC)
```

Score 5 = best in that dimension. Recency is inverted: fewer days since last purchase = higher score.

**Churn classification:**

| Status | Criterion |
|--------|-----------|
| Active | Last purchase ≤ 90 days ago (Oct–Dec 2024) |
| At Risk | Last purchase 91–180 days ago (Jul–Sep 2024) |
| Churned | Last purchase > 180 days ago (before Jul 2024) |

---

## Revenue Trend Analysis

<div align="center">

*Page 1 — Monthly Revenue with dynamic period selector (1W · 1M · 3M · 6M · 9M · 1Y)*

</div>

**Architecture:** All measures compute their date range internally using `EDATE()` and `YYYYMM` arithmetic — no `DATESBETWEEN()` — because PostgreSQL views have no active relationship with `dim_dates` in the Power BI model.

**Key findings:**

- Revenue peaks appear in **Q1 (January)** and **Q4 (November–December)**, consistent with fashion retail seasonal patterns
- The **Moving Average** line (configurable 3M / 6M / 12M window) smooths spikes and confirms an underlying upward trend through Q3
- **MoM Revenue card** compares the last full month vs. the previous month — always anchored to December vs. November regardless of the period slicer selection
- The **period selector** dynamically adjusts all KPI cards, the bar chart, and the comparison subtitle simultaneously via a disconnected table (`Date selection`) with SELECTEDVALUE() bridge

---

## RFM Segmentation Analysis

<div align="center">

*Page 2 — RFM Treemap + Scatter Chart*

</div>

**Segment distribution (treemap):**

| Segment | Condition | Typical Behavior |
|---------|-----------|-----------------|
| Champions | R≥4, F≥4, M≥4 | High frequency, high spend, very recent |
| Loyal Customers | F≥4, M≥3 | Consistent buyers, moderate recency |
| Potential Loyalists | R≥3, F≥2 | Recent but still building frequency |
| At Risk | R≤2, F≥3 | Used to buy often, now inactive |
| Hibernating | R≤2, F≤2 | Low engagement across all dimensions |
| New Customers | R≥4, F≤1 | First purchase was recent |

**Spend & frequency by customer tenure (scatter chart):**

The bubble chart (`avg net_spend` × `months_active`, sized by `total_orders`) reveals two distinct behavioral curves:

- **Loyal Customers** peak at **15–25 months** of tenure, then decline — creating a clear retention risk window
- **Champions** show a **continuously increasing** spend curve up to 75 months — the longer the relationship, the more valuable they become
- A data gap between months 10–30 in Champions reflects the bimodal distribution of acquisition dates in the synthetic dataset

---

## Churn Analysis

<div align="center">

*Page 2 — Dynamic Pie Chart (Bookmarks)*

</div>

The pie chart switches dynamically between **RFM segment view** and **churn status view** via a Bookmark Navigator — two pie charts stacked in the same canvas position, toggled by bookmarks.

> **Technical note (D-011):** Field Parameters with columns from two unrelated tables throw "too many columns in Legend" in pie charts. The bookmark pattern is the correct Power BI approach for this case.

**Churn rate card behavior:**
- Color logic is **inverted** vs. revenue cards: a decrease (▼) is green, an increase (▲) is red
- The `1Y` period uses a fixed Churned count from `v_churn_analysis[churn_status]` rather than a date-range filter — because "Churned" is already defined as > 180 days inactive, so filtering by a 1Y window would double-count

---

## Cohort Retention Analysis

<div align="center">

*Page 2 — Cohort Heatmap (HTML Visual)*

</div>

The cohort matrix tracks what percentage of customers acquired in month M return in months M+1, M+2, M+3...

**How it works:**

```sql
-- Assign each customer to their first-purchase month (cohort)
-- Then LEFT JOIN with subsequent months to tag Retained vs. New
-- retention_pct = customers active in month M / cohort size at M0
```

**Sample output:**

| Cohort | M0 | M1 | M2 | M3 | M4 |
|--------|----|----|----|----|-----|
| 2024-01 | 100% | 59.3% | 63.4% | 60.4% | 58.9% |
| 2024-02 | 100% | 37.0% | 36.6% | 27.9% | 28.7% |
| 2024-03 | 100% | 38.4% | 25.8% | 24.8% | 27.5% |

> The heatmap is rendered as a **DAX HTML measure** (`Cohort Heatmap HTML`) using nested `CONCATENATEX` — one iteration per cohort row, one per month column — with inline CSS color scale. This replaces the native Power BI Matrix visual for full control over empty cells, color gradients, and the absence of a misleading Total column.

**Color scale:**

| Range | Color | Meaning |
|-------|-------|---------|
| ≥ 80% | `#2D6A4F` | Excellent retention |
| 60–79% | `#52B788` | Good |
| 40–59% | `#E9C46A` | Average |
| 20–39% | `#E76F51` | At risk |
| < 20% | `#C05B5B` | Critical |

---

## Dashboard Pages

| Page | Title | Visuals | Status |
|------|-------|---------|--------|
| 1 | Executive KPIs | Bar+line chart · 4 HTML KPI cards · Period slicer | 🔄 In progress |
| 2 | RFM + Retention | Treemap · Scatter · Pie (bookmarks) · Combo chart · Cohort heatmap | 🔄 In progress |
| 3 | Churn Analysis | — | ⏳ Pending |
| 4 | Monthly Revenue | Deneb Vega-Lite bar+line chart | 🔄 Active |

**Power BI model relationships:**

```
dim_customers    ──► v_rfm_segments      (customer_id)
dim_customers    ──► v_churn_analysis    (customer_id)
dim_sales_outlet ──► v_rfm_segments      (sales_outlet_id → home_store)
v_monthly_revenue ──► v_monthly_retention (year_month_key)  [One-to-One]
```

> `year_month_key = year_id * 100 + month_id` — created in Power Query on both tables to enable a single-column relationship between monthly views (D-012).

---

## Recommendations

### Revenue
- **Capitalize on Q1 momentum.** January shows the highest revenue peaks — launch loyalty campaigns in December to prime customers for Q1 purchasing.
- **Investigate Q3 softness.** The moving average confirms a mid-year dip. A targeted mid-year promotion (July) could smooth the seasonal curve.

### RFM Segmentation
- **Intervene on Loyal Customers at months 24–28.** The scatter chart shows a sharp spend decline after month 25. A personalized win-back offer at this tenure milestone could push them into Champions.
- **Protect Champions at all costs.** Their value increases with time — churn prevention for this segment has the highest ROI of any retention investment.
- **Re-engage At Risk customers with high F/M scores.** They used to buy frequently and spend well; a "we miss you" campaign with an exclusive incentive has a strong behavioral foundation.

### Churn
- **Target the At Risk cohort before they cross 180 days.** The churn classification flips at 180 days — intervening at days 120–150 gives a 30–60 day window before a customer becomes Churned.
- **Monitor new customers at Month 1.** Cohort retention data shows the steepest drop between M0 and M1. An onboarding email sequence post-first-purchase could significantly improve this rate.

### Cohort Retention
- **January and February cohorts retain best.** These are the highest-quality acquisition months — marketing spend on customer acquisition is most efficient in Q1.
- **Late-year cohorts (Oct–Dec) have very thin M1 data.** Either improve post-purchase engagement for these customers, or adjust acquisition spend downward in Q4 and shift budget to retention.

---

## Technical Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| RFM scoring | NTILE(5) | Creates equal-sized groups — more stable than fixed thresholds |
| Filter strategy | Internal FILTER + YYYYMM arithmetic | `DATESBETWEEN` doesn't propagate to PostgreSQL views (no active relationship) |
| Slicer architecture | Disconnected tables + SELECTEDVALUE() | Keeps fact tables clean; avoids model contamination |
| Pie chart switching | Bookmarks + 2 stacked visuals | Field Parameters fail with unrelated tables in Legend bucket |
| Cohort heatmap | DAX HTML measure | Full CSS control — no misleading Total column, clean empty cells |
| Monthly granularity | `v_monthly_revenue` (not daily) | 366 bars per year are unreadable; monthly view is analytically sufficient |
| Return rate | 0.72% (~1,572 returns) | Based on `unit_price` × 1 unit per return, not `line_total` |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Data Generation | Python (Pandas, NumPy, Faker) |
| Database | PostgreSQL 16 — `vistara_db`, schema `vistara` |
| ORM / Driver | Npgsql (Power BI connector) |
| Semantic Model | Power BI Desktop (Import mode) |
| Custom Visuals | Deneb (Vega-Lite 6) · HTML Viewer |
| DAX Patterns | SWITCH · SELECTEDVALUE · CONCATENATEX · GENERATESERIES · EDATE |
| SQL Patterns | CTE chains · NTILE · LAG · DATE_TRUNC · AGE · Window functions |
| Documentation | Obsidian (wiki vault) |

---

<div align="center">

*VISTARA is a fictional brand created for educational and portfolio purposes.*  
*All data is synthetically generated — no real customer information is used.*

</div>
