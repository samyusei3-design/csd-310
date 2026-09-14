#Samuel Guizar
#9/10/26
#Module 6.2 Assignment


import mysql.connector
from mysql.connector import errorcode

import dotenv
from dotenv import dotenv_values

secrets = dotenv_values(".env")
print(secrets)

config = {
    "user": secrets["USER"],
    "password": secrets["PASSWORD"],
    "host": secrets["HOST"],
    "database": secrets["DATABASE"],
    "raise_on_warnings": True
}

try:

    db = mysql.connector.connect(**config)

    #Create cursor
    cursor = db.cursor()

    #Display studio records
    print("\n-- DISPLAYING Studio RECORDS --")
    cursor.execute("SELECT * FROM studio")
    studios = cursor.fetchall()

    for studio in studios:
        print("Studio ID: {}\nStudio Name: {}\n".format(studio[0], studio[1]))

    #Display genre records
    print("-- DISPLAYING Genre RECORDS --")
    cursor.execute("SELECT * FROM genre")
    genres = cursor.fetchall()

    for genre in genres:
        print("Genre ID: {}\nGenre Name: {}\n".format(genre[0], genre[1]))

    #Display movies with less than 2 hour runtime
    print("-- DISPLAYING Short Film RECORDS --")
    cursor.execute("SELECT film_name, film_runtime FROM film WHERE film_runtime < 120")
    films = cursor.fetchall()

    for film in films:
        print("Film Name: {}\nRuntime: {} minutes\n".format(film[0], film[1]))

    #Display director records in order
    print("-- DISPLAYING Director RECORDS in Order --")
    cursor.execute("SELECT film_name, film_director FROM film ORDER BY film_director")
    films = cursor.fetchall()

    for film in films:
        print("Film Name: {}\nDirector: {}\n".format(film[0], film[1]))

except mysql.connector.Error as err:

    if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
        print("  The supplied username or password are invalid")

    elif err.errno == errorcode.ER_BAD_DB_ERROR:
        print("  The specified database does not exist")

    else:
        print(err)

finally:

    if db.is_connected():
        cursor.close()
        db.close()