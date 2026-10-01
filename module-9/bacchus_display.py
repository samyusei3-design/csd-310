"""Group D - Bacchus Winery Milestone 2
Displays the contents of every Bacchus Winery table.
Install connector if needed: python3 -m pip install mysql-connector-python
"""
import mysql.connector
from mysql.connector import Error

DB_CONFIG = {
    "host": "localhost",
    "user": "root",          # change if your MySQL username is different
    "password": "Password",  # replace with your MySQL password
    "database": "bacchus_winery",
}

TABLES = [
    "department", "employee", "employee_time_record", "supplier", "item",
    "supplier_item", "purchase_order", "purchase_order_item", "supplier_shipment",
    "wine", "distributor", "distributor_order", "distributor_order_item",
    "inventory", "sales_report"
]

def display_table(cursor, table_name):
    cursor.execute(f"SELECT * FROM `{table_name}`")
    rows = cursor.fetchall()
    headers = [column[0] for column in cursor.description]
    print("\n" + "=" * 90)
    print(f"DISPLAYING {table_name.upper()}")
    print("=" * 90)
    print(" | ".join(headers))
    print("-" * 90)
    for row in rows:
        print(" | ".join("NULL" if value is None else str(value) for value in row))
    print(f"Rows displayed: {len(rows)}")

def display_quarterly_hours(cursor):
    query = """
        SELECT e.employee_id,
               CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
               YEAR(t.work_date) AS work_year,
               QUARTER(t.work_date) AS work_quarter,
               SUM(t.hours_worked) AS total_hours
        FROM employee e
        JOIN employee_time_record t ON e.employee_id = t.employee_id
        GROUP BY e.employee_id, employee_name, YEAR(t.work_date), QUARTER(t.work_date)
        ORDER BY work_year, work_quarter, e.employee_id
    """
    cursor.execute(query)
    print("\n" + "=" * 90)
    print("EMPLOYEE HOURS BY QUARTER")
    print("=" * 90)
    for employee_id, employee_name, year, quarter, hours in cursor.fetchall():
        print(f"{employee_id}: {employee_name} | {year} Q{quarter} | {hours} hours")

def main():
    connection = None
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()
        print("Connected to the Bacchus Winery database.")
        for table in TABLES:
            display_table(cursor, table)
        display_quarterly_hours(cursor)
        cursor.close()
    except Error as err:
        print(f"Database error: {err}")
        print("Check that MySQL is running and update DB_CONFIG with your username/password.")
    finally:
        if connection and connection.is_connected():
            connection.close()
            print("\nMySQL connection closed.")

if __name__ == "__main__":
    main()
