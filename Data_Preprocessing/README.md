## 🧹 Data Preprocessing & Quality Audit (Microsoft Excel)

Before initiating database ingestion or front-end visualization, a comprehensive data profiling and restructuring phase was executed on all **9 core Olist datasets** using Microsoft Excel. This critical layer establishes our analytical "Source of Truth" baseline and ensures absolute data integrity across downstream platforms.

### 🛠️ Key Data Transformations Executed:
* **String Standardization:** Handled trailing spaces and inconsistent text casing across geographic fields using `TRIM()` and `PROPER()` to ensure error-free relational database joins.
* **Entity Deduplication:** Executed targeted row deduplication on spatial variables within the geolocation data to eliminate duplicate key instances and prevent relationship ambiguity in Power BI.
* **Structural Blank Handling:** Isolated structural empty cells in operational order lifecycle tracking columns to safeguard downstream MySQL processing, ensuring blank fields translate to true database `NULL` values rather than breaking ingestion scripts.
* **Data Typology Integrity:** Converted large alphanumeric string hashes explicitly into **Text Format** blocks to permanently prevent scientific notation corruption (e.g., `3.5E+11`) on primary/foreign keys.

### 📈 Verified Ingestion Baselines (Source of Truth):
* **Total Audited Orders:** 99,441 unique operational records.
* **Total Portfolio Revenue:** 16,008,872.12 total portfolio currency units.
* **Valid Product Categories:** 71 verified categories mapping to English translations.

*For a granular dataset-by-dataset breakdown of the exact problems identified and resolved, please refer to the comprehensive [data_cleaning_documentation.docx](./data_cleaning_documentation.docx) asset stored within this directory.*
