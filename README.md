# Logistics and Supply Chain Analysis: A Data-Driven Optimization Project

## 1. Project Overview

This project provides a comprehensive, end-to-end analysis of a logistics network dataset from a major Southern California network. The objective was to leverage data analysis to identify key drivers of delivery performance, operational costs, and risks. The final deliverables include a professional report and two interactive dashboards built to provide actionable insights for process optimization.

---

## 2. Key Insights

* **Cost Drivers:** Major delays were identified as the primary contributor to higher shipping costs and fuel consumption.
* **Risk Mitigation:** A strong correlation was established between high-risk routes and increased delivery deviation, with specific geographic hotspots identified via a map visualization.
* **Operational Efficiency:** The analysis revealed that factors beyond simple warehouse inventory levels—such as time of day and external conditions—are significant contributors to unfulfilled orders and delivery delays.
* **Predictive Analytics:** An enriched dataset with new features was created, and its application demonstrated that while some insights can be gained, a direct correlation between predicted delay probability and actual ETA variation was not found, highlighting an area for further model development.

---

## 3. Methodology

This project followed a full data analysis lifecycle, showcasing proficiency in a variety of tools and techniques.

### **Phase 1: Data Preparation & Advanced SQL**

* **Database:** A MySQL database was used to store and manipulate the raw data.
* **Data Modeling:** The raw data was transformed into a **star schema**, with a `Fact_Deliveries` table and corresponding dimension tables (`Dim_Time`, `Dim_Routes`, `Dim_Suppliers`), to structure the data for efficient reporting.
* **Feature Engineering:** Advanced **SQL** queries were used to create new, relevant features from existing data, such as `Is_Weekend` and `Time_of_Day_Category`, to enhance predictive insights.
* **Analysis:** Performed aggregate analysis and used **window functions** (e.g., `LAG`, rolling `AVG`) to analyze performance trends.

### **Phase 2: Visualization & Reporting**

* **Power BI:** An interactive, multi-page dashboard was developed to visualize the project's key findings. Visualizations included a map for geographic analysis, a treemap for risk assessment, and a clustered bar chart for cost analysis.
* **Tableau:** A separate, visually compelling dashboard was created to demonstrate a different approach to data storytelling. It included a packed bubble chart for cost distribution and a time-series line chart for performance trends.

---

## 4. Tools & Technologies

* **Database:** MySQL
* **Data Manipulation:** SQL
* **Business Intelligence:** Power BI, Tableau
* **Version Control:** Git, GitHub

---

## 5. Repository Files

* `SQL/`: All SQL scripts used for data modeling, cleaning, and analysis.
* `Dashboards/`: The Power BI (`.pbix`) and Tableau (`.twbx`) project files.
* `Data/`: The CSV files used for data import and export.
* `Report.pdf`: A full report of the project, including the executive summary, methodology, and recommendations.

---

### **Contact**

For any questions or further discussion about this project, please feel free to reach out.

Kodari Sravan

sravankodari4@gmail.com