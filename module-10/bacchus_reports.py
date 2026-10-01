#Bacchus Winery - Milestone 3 Reports
#Group D - Verdis Moorer and Samuel Guizar


#Creates reports from the bacchus_winery MySQL database

import mysql.connector
from datetime import date
from tabulate import tabulate


#Connect to the MySQL database
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "YourPasswordHere",  #Replace with your MySQL root password
    "database": "bacchus_winery"
}


#Display report results in a formatted table
def display_report(title, rows):

    print("\n" + title.upper())
    
    if not rows:
        print("No records were found for this report.")
    else:
        # Display results using a bordered ASCII table
        print(tabulate(
            rows,
            headers="keys",
            tablefmt="psql",
            floatfmt=".1f"
        ))


#Display supplier delivery information
def supplier_delivery_report(connection):

    query = """
        SELECT
            s.supplier_name AS Supplier,
            po.purchase_order_id AS Purchase_Order,
            po.order_date AS Order_Date,
            po.expected_delivery_date AS Expected_Delivery,
            sh.shipping_date AS Shipping_Date,
            sh.expected_arrival_date AS Expected_Arrival,
            sh.actual_arrival_date AS Actual_Arrival,
            sh.tracking_number AS Tracking_Number
        FROM supplier AS s
        JOIN purchase_order AS po
            ON s.supplier_id = po.supplier_id
        LEFT JOIN supplier_shipment AS sh
            ON po.purchase_order_id = sh.purchase_order_id
        ORDER BY s.supplier_name, po.order_date
    """

    cursor = connection.cursor(dictionary=True)
    cursor.execute(query)
    rows = cursor.fetchall()

    display_report("Supplier Delivery Report", rows)

    cursor.close()


#Display wine sales information
def wine_sales_report(connection):

    query = """
        SELECT
            sr.report_date AS Report_Date,
            d.distributor_name AS Distributor,
            w.wine_name AS Wine,
            w.wine_type AS Wine_Type,
            sr.quantity_sold AS Quantity_Sold
        FROM sales_report AS sr
        JOIN distributor AS d
            ON sr.distributor_id = d.distributor_id
        JOIN wine AS w
            ON sr.wine_id = w.wine_id
        ORDER BY sr.report_date, w.wine_name
    """

    cursor = connection.cursor(dictionary=True)
    cursor.execute(query)
    rows = cursor.fetchall()

    display_report("Wine Sales Report", rows)

    cursor.close()


#Display distributor orders information
def distributor_orders_report(connection):

    query = """
        SELECT
            d.distributor_name AS Distributor,
            w.wine_name AS Wine,
            w.wine_type AS Wine_Type,
            COUNT(*) AS Number_of_Items,
            SUM(doi.quantity_ordered) AS Total_Quantity,
            SUM(doi.quantity_ordered * doi.sale_price) AS Total_Value
        FROM distributor AS d
        JOIN distributor_order AS ord
            ON d.distributor_id = ord.distributor_id
        JOIN distributor_order_item AS doi
            ON ord.distributor_order_id = doi.distributor_order_id
        JOIN wine AS w
            ON doi.wine_id = w.wine_id
        GROUP BY
            d.distributor_name,
            w.wine_name,
            w.wine_type
        ORDER BY
            d.distributor_name,
            w.wine_name
    """

    cursor = connection.cursor(dictionary=True)
    cursor.execute(query)
    rows = cursor.fetchall()

    display_report("Distributor Orders Report", rows)

    cursor.close()


#Display employee hours by quarter
def employee_hours_report(connection):

    today = date.today()
    current_quarter_start_month = ((today.month - 1) // 3) * 3 + 1

    end_date = date(
        today.year,
        current_quarter_start_month,
        1
    )

    start_date = date(
        end_date.year - 1,
        end_date.month,
        1
    )

    query = """
        SELECT
            e.employee_id AS Employee_ID,
            e.first_name AS First_Name,
            e.last_name AS Last_Name,
            e.job_title AS Job_Title,
            d.department_name AS Department,
            YEAR(etr.work_date) AS Year,
            QUARTER(etr.work_date) AS Quarter,
            SUM(etr.hours_worked) AS Total_Hours
        FROM employee AS e
        JOIN department AS d
            ON e.department_id = d.department_id
        JOIN employee_time_record AS etr
            ON e.employee_id = etr.employee_id
        WHERE etr.work_date >= %s
          AND etr.work_date < %s
        GROUP BY
            e.employee_id,
            e.first_name,
            e.last_name,
            e.job_title,
            d.department_name,
            YEAR(etr.work_date),
            QUARTER(etr.work_date)
        ORDER BY
            e.last_name,
            e.first_name,
            YEAR(etr.work_date),
            QUARTER(etr.work_date)
    """

    cursor = connection.cursor(dictionary=True)
    cursor.execute(query, (start_date, end_date))
    rows = cursor.fetchall()

    print(
        f"\nReporting period: {start_date} "
        f"through {end_date} (end date not included)"
    )

    display_report("Employee Quarterly Hours Report", rows)

    cursor.close()


#Display inventory report
def inventory_report(connection):

    query = """
        SELECT
            inv.inventory_id AS Inventory_ID,
            inv.inventory_type AS Inventory_Type,
            i.item_name AS Supply_Item,
            i.item_type AS Supply_Type,
            w.wine_name AS Wine,
            w.wine_type AS Wine_Type,
            inv.quantity_on_hand AS Quantity_On_Hand,
            inv.last_updated AS Last_Updated
        FROM inventory AS inv
        LEFT JOIN item AS i
            ON inv.item_id = i.item_id
        LEFT JOIN wine AS w
            ON inv.wine_id = w.wine_id
        ORDER BY inv.inventory_type, inv.inventory_id
    """

    cursor = connection.cursor(dictionary=True)
    cursor.execute(query)
    rows = cursor.fetchall()

    display_report("Supply and Wine Inventory Report", rows)

    cursor.close()


#Connect to the database and run the reports
def main():

    try:
        connection = mysql.connector.connect(**DB_CONFIG)

        print("Connected to the Bacchus Winery database.")

        supplier_delivery_report(connection)
        wine_sales_report(connection)
        distributor_orders_report(connection)
        employee_hours_report(connection)
        inventory_report(connection)

        connection.close()

        print("\nMySQL connection closed.")

    except mysql.connector.Error as error:
        print(f"Database error: {error}")
        print("Check that MySQL is running and the database tables exist.")


if __name__ == "__main__":
    main()