#Samuel Guizar
#9/15/26
#Module 7.2 Assignment


import mysql.connector
from mysql.connector import errorcode

import dotenv
from dotenv import dotenv_values

secrets = dotenv_values(".env")

config = {
    "user": secrets["USER"],
    "password": secrets["PASSWORD"],
    "host": secrets["HOST"],
    "database": secrets["DATABASE"],
    "raise_on_warnings": True
}

def show_films(cursor, title):
    cursor.execute("""SELECT film_name AS Name,
        film_director AS Director,
        genre_name AS Genre,
        studio_name AS Studio
        FROM film
        INNER JOIN genre ON film.genre_id = genre.genre_id
        INNER JOIN studio ON film.studio_id = studio.studio_id""")

    films = cursor.fetchall()
    print("\n -- {} --".format(title))
    for film in films:
        print("Name: {}\n"
              "Director: {}\n"
              "Genre: {}\n"
              "Studio: {}\n".format(film[0], film[1], film[2], film[3]))

try:

    db = mysql.connector.connect(**config)

    #Create cursor
    cursor = db.cursor()

    #Display films
    show_films(cursor, "DISPLAYING FILMS")

    #Insert new film
    cursor.execute("""INSERT INTO film
          (film_name, film_releaseDate, film_runtime, film_director, genre_id, studio_id)
          VALUES
          ('Titanic', '1997', 195, 'James Cameron',
          (SELECT genre_id FROM genre WHERE genre_name = 'Drama'),
          (SELECT studio_id FROM studio WHERE studio_name = '20th Century Fox'))""")
  
    db.commit()

    #Display films after insert
    show_films(cursor, "DISPLAYING FILMS AFTER INSERT")

    #Change Alien genre to Horror
    cursor.execute("""Update film
        SET genre_id = (
        SELECT genre_id
        FROM genre
        WHERE genre_name = 'Horror')
        WHERE film_name = 'Alien'""")

    db.commit()

    #Display films after update
    show_films(cursor, "DISPLAYING FILMS AFTER UPDATE")

    #Delete Gladiator film
    cursor.execute("""DELETE FROM film
        WHERE film_name = 'Gladiator'""")

    db.commit()

    #Display films after delete
    show_films(cursor, "DISPLAYING FILMS AFTER DELETE")


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