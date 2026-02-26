# F1 StatsHub

F1 StatsHub is a database management and visualization dashboard built with Streamlit and MySQL. It allows users to manage Formula 1 race results, driver information, and constructor data while utilizing advanced database features like triggers, stored procedures, and custom functions to maintain data integrity and automate calculations.

---

## Features

### Race Results Management
- View, add, delete, and modify race results.

### Automated Point Scoring
- A database trigger automatically assigns FIA standard points (25, 18, 15, 12, 10, 8, 6, 4, 2, 1) based on finishing position.

### Position Swapping
- A stored procedure swaps finishing positions between two drivers in a specific race.
- Automatically recalculates ranks after swapping.

### Standings Visualization
- Real-time World Drivers' Championship (WDC) table.
- Real-time World Constructors' Championship (WCC) table.

### Advanced Querying
- Nested queries to identify drivers who scored points in every race they participated in.

### Administrative Tools
- Create database users.
- Grant specific privileges (SELECT, INSERT, UPDATE, DELETE) directly from the UI.

---

## Tech Stack

- Frontend: Streamlit (Python)
- Database: MySQL
- Data Handling: Pandas
- Environment Management: Python OS module for secure database credentials

---

## Database Logic

### Functions

**getDriverFullName**
- Concatenates driver forename and surname for cleaner reporting.

### Triggers

**trg_results_before_insert**
- Automatically calculates and inserts points based on the Position_Order if points are not provided.

**PreventDuplicateResults**
- Ensures data integrity by blocking duplicate entries for the same driver, constructor, and position in a single race.

### Stored Procedures

**add_result**
- Validates foreign keys (Race, Driver, Constructor, Car, Status).
- Inserts a new result.
- Recalculates race ranks.

**swap_driver_positions**
- Swaps the finishing order of two drivers.
- Triggers rank recalculation.

**RecalculateAllRaceRanks**
- Uses window functions or variables to ensure the RaceRank column is synchronized with Position_Order.

**assign_points_for_race**
- Bulk updates points for an entire race event.

**delete_result**
- Safely removes a result tuple based on specific identifiers.

---

## Installation and Setup

### 1. Database Configuration

Execute the provided SQL logic in your MySQL instance to create the necessary functions, triggers, and procedures.

Ensure your database is named:

F1

---

### 2. Environment Variables

Set the following environment variables on your system:

MYSQLHOST=localhost  
MYSQLUSER=your_username  
MYSQLPASSWORD=your_password  
MYSQLDATABASE=F1  
MYSQLPORT=3306  

---

### 3. Install Dependencies

```bash
pip install streamlit mysql-connector-python pandas
```

---

### 4. Run the Application

```bash
streamlit run app.py
```

---

### F1_Frontend.py
Contains:
- Streamlit UI logic
- Database connection bridge
- Query execution and visualization

### SQL Logic Includes
- Table definitions (Drivers, Constructors, Races, Results, etc.)
- Stored Procedures for data manipulation
- Triggers for automated point assignments
- Functions for data formatting

---

## Usage Guide

### Results
View the master results table with full driver names.

### Results Manipulation
- Add new entries using forms.
- Swap driver positions.
- Delete specific records.

### Standings
- View automatically aggregated WDC standings.
- View automatically aggregated WCC standings.

### Nested Query Analytics
Run specialized analytics to find the most consistent point scorers.

### Admin
Manage database-level access and user permissions directly from the UI.
