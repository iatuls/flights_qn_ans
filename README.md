# ✈️ Flight Data Cleaning & SQL Analysis

Cleaning a raw Indian domestic flights dataset and answering 18 business questions with SQL (MySQL).

##  Overview

This project takes a raw flight-fare dataset, cleans and restructures it directly in SQL, and then uses the cleaned table to answer practical questions about flight volume, pricing, duration, routes and airline behaviour.

The focus is on **data cleaning with SQL** and **date/time manipulation**, plus window functions, CTEs, conditional aggregation and pivot-style grids.

##  Repository Structure

```
├── flights.sql                  # Cleaning steps + 18 analysis queries (questions as comments)
├── flights_cleaned_dataset.csv  # Cleaned dataset (10,682 rows)
├── raw dataset                  # Original data before cleaning
└── README.md
```

##  Dataset

The cleaned dataset has **10,682 flights** and these columns:

| Column | Description |
|---|---|
| `Airline` | Airline name (Jet Airways, IndiGo, Air India, ...) |
| `Source` | City of departure (Banglore, Chennai, Delhi, Kolkata, Mumbai) |
| `Destination` | City of arrival (New Delhi, Cochin, Kolkata, Banglore, Hyderabad, Delhi) |
| `Total_Stops` | non-stop, 1 stop, 2 stops, 3 stops, 4 stops |
| `Additional_Info` | Extra notes such as "No info" or "1 Long layover" |
| `Price` | Ticket price |
| `departure` | Departure date and time (DATETIME) |
| `duration_min` | Flight duration in minutes (INTEGER) |
| `arrival` | Arrival date and time (DATETIME) |

##  Data Cleaning Steps

1. **Removed an invalid record**: deleted a row with an unrealistic flight duration of `5m`.
2. **Built a proper `departure` timestamp**: combined the separate `Date_of_journey` and `Dep_Time` text columns into one `DATETIME` column using `STR_TO_DATE` and `CONCAT`.
3. **Converted duration to minutes**: parsed text like `"2h 50m"` into an integer `duration_min` column using `SUBSTRING_INDEX`, `REPLACE` and `CASE` (including values with only hours, like `"5h"`).
4. **Derived the `arrival` timestamp**: calculated it as `departure + duration_min` using `DATE_ADD`.
5. **Dropped redundant columns**: removed `Duration`, `Date_of_journey` and `Dep_Time` once they were replaced by the cleaner columns.

##  Questions Answered

### Before restructuring (using the original date/time columns)
1. Which month has the most flights?
2. Which weekday has the most expensive flights (by average price)?
3. How many IndiGo flights run each month?
4. List all flights from Banglore to Delhi departing between 10 AM and 2 PM.
5. How many flights depart from Banglore on weekends?

### After restructuring (using `departure`, `arrival`, `duration_min`)
6. Calculate the arrival time for every flight.
7. Calculate the arrival date for every flight.
8. How many flights per airline run on each date?
9. What is the average flight duration for each city pair, in hours and minutes?
10. Which non-stop flights depart on one day and arrive after midnight on the next?
11. How many flights does each airline operate per quarter?
12. What are the longest flights (by time) in the dataset?
13. How do duration and price compare for non-stop, 1-stop and multi-stop flights?
14. Which flights from Delhi depart between 1 and 10 March 2019?
15. What is the longest flight of each airline?
16. Which city pairs have an average duration above 3 hours?
17. Weekday vs time-of-day grid: flight frequency from Banglore to Delhi.
18. Weekday vs time-of-day grid: average price from Banglore to Delhi.

##  SQL Concepts Used

- Date and time functions: `MONTHNAME`, `DAYNAME`, `HOUR`, `DATE`, `TIME`, `STR_TO_DATE`, `DATE_ADD`, `TIMESTAMPDIFF`, `DATE_FORMAT`
- String functions: `SUBSTRING_INDEX`, `REPLACE`, `CONCAT`
- Aggregations with `GROUP BY` and `HAVING`
- Subqueries and CTEs (`WITH`)
- Window functions (`ROW_NUMBER() OVER (PARTITION BY ...)`)
- Conditional logic with `CASE WHEN`, including pivot-style grids
- `ALTER TABLE`, `UPDATE` and `DELETE` for in-database cleaning

##  How to Run

1. Create a database and import the raw flights CSV into a table named `flights` (for example with MySQL Workbench's Table Data Import Wizard).
2. Open `flights.sql` in MySQL Workbench (or any MySQL client).
3. Run the cleaning section first. It is order-dependent, because Questions 1 to 5 use the original columns and Questions 6 to 18 use the new ones.
4. Run each query to see its result.

> Requires **MySQL 8.0+** (window functions and CTEs).

##  Notes

- City names follow the original data spelling (e.g. `Banglore`).
- `Delhi` and `New Delhi` both appear as destinations in the dataset.

##  Tech Stack

MySQL · MySQL Workbench · CSV

---

⭐ If you found this useful, consider giving the repo a star!
