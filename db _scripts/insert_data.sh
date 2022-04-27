#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ ! $WINNER == "winner" || ! $OPPONENT == "opponent" ]] 
  then
    CHECK_WINNER=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
    if [[ -z $CHECK_WINNER ]]
    then
      TEAM_TO_ENTER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    fi
    CHECK_OPPONENT=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
    if [[ -z $CHECK_OPPONENT ]]
    then
      TEAM_TO_ENTER=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    fi
  fi

  if [[ ! $YEAR == "year" || ! $ROUND == "round" || ! $WINNER_GOALS == "winner_goals" || ! $OPPONENT_GOALS == "opponent_goals" ]] 
  then  
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    GAME_EXISTS=$($PSQL "SELECT game_id FROM games WHERE winner_id=$WINNER_ID AND opponent_id=$OPPONENT_ID")
    if [[ -z $GAME_EXISTS ]]
    then
      GAME_TO_ENTER=$($PSQL "INSERT INTO games(year,round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_ID, $OPPONENT_ID)")
    fi
  fi
done
