#!/bin/bash

echo "Enter your username:"
read USERNAME

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER=$(( RANDOM % 1000 + 1 ))
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  USER_NAME=$($PSQL "SELECT username FROM users WHERE user_id=$USER_ID")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")   
  echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

NEW_GAME=$($PSQL "INSERT INTO games(user_id,secret_number) VALUES($USER_ID,$NUMBER)")
GAME_ID=$($PSQL "SELECT game_id FROM games where user_id='$USER_ID' ORDER BY game_id DESC LIMIT 1")
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=(games_played+1) WHERE user_id=$USER_ID")

echo "Guess the secret number between 1 and 1000:"

FLAG="0"
  while [[ $FLAG == "0" ]]
  read USER_GUESS
  do
    if ! [[ "$USER_GUESS" =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
       
    elif [[ $USER_GUESS -gt $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      NEW_GUESS=$($PSQL "INSERT INTO guesses(game_id,number) VALUES($GAME_ID,$USER_GUESS)")
      
    elif [[ $USER_GUESS -lt $NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      NEW_GUESS=$($PSQL "INSERT INTO guesses(game_id,number) VALUES($GAME_ID,$USER_GUESS)")

    else 
      NEW_GUESS=$($PSQL "INSERT INTO guesses(game_id,number) VALUES($GAME_ID,$USER_GUESS)")
      SET_WIN=$($PSQL "UPDATE games SET win=1 WHERE game_id='$GAME_ID'")

      NUMBER_OF_GUESSES=$($PSQL "SELECT COUNT(*) FROM guesses WHERE game_id='$GAME_ID'")
      NEW_BEST_GAME=$($PSQL "SELECT COUNT(guess_id) FROM games JOIN guesses USING(game_id) WHERE user_id=$USER_ID GROUP BY game_id ORDER BY COUNT(guess_id) LIMIT 1")
            
      if [[ $NUMBER_OF_GUESSES -gt $NEW_BEST_GAME ]] 
      then
        SET_BEST=$($PSQL "UPDATE users SET best_game=$NEW_BEST_GAME")
      else
        SET_BEST=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES")
      fi
      
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"
      FLAG="1"
      exit  
    fi
  done



