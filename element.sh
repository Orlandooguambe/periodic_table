#!/bin/bash

# Connect to the PostgreSQL database
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if an argument was provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  # Determine if the input is an atomic number, symbol, or name
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # Input is an atomic number
    ELEMENT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius 
                     FROM elements 
                     INNER JOIN properties USING(atomic_number) 
                     INNER JOIN types USING(type_id) 
                     WHERE atomic_number=$1")
  elif [[ $1 =~ ^[a-zA-Z]{1,2}$ ]]
  then
    # Input is an element symbol
    ELEMENT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius 
                     FROM elements 
                     INNER JOIN properties USING(atomic_number) 
                     INNER JOIN types USING(type_id) 
                     WHERE symbol='$1'")
  else
    # Input is an element name
    ELEMENT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius 
                     FROM elements 
                     INNER JOIN properties USING(atomic_number) 
                     INNER JOIN types USING(type_id) 
                     WHERE name='$1'")
  fi

  # Check if the element was found
  if [[ -z $ELEMENT ]]
  then
    echo "I could not find that element in the database."
  else
    # Parse the results and display the information
    IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT <<< $ELEMENT
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
fi
