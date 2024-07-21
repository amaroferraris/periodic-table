#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# Check if any argument is provided
if [ -z $1 ];
  then
    echo "Please provide an element as an argument."
  else

  NUMBER_PATTERN='^[0-9]*\.?[0-9]+$'

  if [[ $1 =~ $NUMBER_PATTERN ]]
  then
    QUERY=$($PSQL "SELECT elements.name, elements.symbol, type, types.type_id, elements.atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN types ON properties.type_id = types.type_id INNER JOIN elements ON properties.atomic_number = elements.atomic_number WHERE elements.atomic_number = $1;")
    if [[ -z $QUERY ]]
    then
      echo "I could not find that element in the database."
    else
      echo $QUERY | while IFS="|" read NAME SYMBOL TYPE TYPE_ID ATOMIC_NUMBER ATOMIC_MASS MELTING_POINT BOILING_POINT
      do
        echo "The element with atomic number $(echo $ATOMIC_NUMBER | sed -r 's/^ *| *$//g') is $(echo $NAME | sed -r 's/^ *| *$//g') ($(echo $SYMBOL | sed -r 's/^ *| *$//g')). It's a $(echo $TYPE | sed -r 's/^ *| *$//g'), with a mass of $(echo $ATOMIC_MASS | sed -r 's/^ *| *$//g') amu. $(echo $NAME | sed -r 's/^ *| *$//g') has a melting point of $(echo $MELTING_POINT | sed -r 's/^ *| *$//g') celsius and a boiling point of $(echo $BOILING_POINT | sed -r 's/^ *| *$//g') celsius."
      done
    fi
  else
    QUERY=$($PSQL "SELECT elements.name, elements.symbol, type, types.type_id, elements.atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN types ON properties.type_id = types.type_id INNER JOIN elements ON properties.atomic_number = elements.atomic_number WHERE symbol = '$1' OR name = '$1';")
    if [[ -z $QUERY ]]
    then
      echo "I could not find that element in the database."
    else
      echo $QUERY | while IFS="|" read NAME SYMBOL TYPE TYPE_ID ATOMIC_NUMBER ATOMIC_MASS MELTING_POINT BOILING_POINT
      do
        echo "The element with atomic number $(echo $ATOMIC_NUMBER | sed -r 's/^ *| *$//g') is $(echo $NAME | sed -r 's/^ *| *$//g') ($(echo $SYMBOL | sed -r 's/^ *| *$//g')). It's a $(echo $TYPE | sed -r 's/^ *| *$//g'), with a mass of $(echo $ATOMIC_MASS | sed -r 's/^ *| *$//g') amu. $(echo $NAME | sed -r 's/^ *| *$//g') has a melting point of $(echo $MELTING_POINT | sed -r 's/^ *| *$//g') celsius and a boiling point of $(echo $BOILING_POINT | sed -r 's/^ *| *$//g') celsius."
      done
    fi
  fi
fi
