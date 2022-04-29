#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

OUTPUT_RESULT(){

  if ! [[ "$1" =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER="$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1' OR name='$1'")"
  else
    ATOMIC_NUMBER="$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")"
  fi

  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo -e "I could not find that element in the database."
    exit
  else
    RESULT="$($PSQL "SELECT * FROM elements JOIN properties USING(atomic_number) JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")"
    echo $RESULT | while IFS="|" read TYPE_ID ATOMIC_NO SYMBOL NAME ATOMIC_MASS MPC BPC TYPE
  do
    echo -e "The element with atomic number $ATOMIC_NO is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MPC celsius and a boiling point of $BPC celsius.\n"
    exit
  done
  fi 
}

if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument."
  read ELEMENT 
  OUTPUT_RESULT $ELEMENT
else 
  OUTPUT_RESULT $1
fi
