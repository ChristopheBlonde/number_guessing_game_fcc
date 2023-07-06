#!/bin/bash

echo -e "\n~~~~~ Number Guessing Game ~~~~~\n"

# connect database
PSQL="psql -U freecodecamp -d number_guess -t -c"

# functions

# get secret number
RANDOM_NUMBER(){
SECRET_NUMBER=$((RANDOM%1000 + 1))
}

# start
MAIN_MENU(){
echo "Enter your username:"
read USER_NAME
USER_NAME_RESULT=$($PSQL "SELECT * FROM users WHERE user_name='$USER_NAME'")
# echo $USER_NAME_RESULT
if [[ -z $USER_NAME_RESULT ]]
  then
  # if not found
    INSERT_USER
  else
  # get user
    echo "$USER_NAME_RESULT" | while read USER_ID BAR USER_NAME
    do
    # get info games
    INFO_GAMES_RESULT=$($PSQL "SELECT COUNT(*),MIN(try) FROM games WHERE user_id=$USER_ID;")
    echo "$INFO_GAMES_RESULT" | while read COUNT BAR TRY
    do
    if [[ -z $TRY ]]
    then
    TRY=0
    fi 
    # send message
    echo -e "\nWelcome back, $USER_NAME! You have played $COUNT games, and your best game took $TRY guesses."
    done
    done
  # start game
    PLAY_GAME
fi
}

# insert user
INSERT_USER(){
  # insert new user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(user_name) VALUES('$USER_NAME');")
  # send message
  echo -e "\nWelcome, $USER_NAME! It looks like this is your first time here."
  # start game
  PLAY_GAME  
}

# play game
PLAY_GAME(){
  # random a number and create count
  RANDOM_NUMBER
  COUNT_TRY=0
  # read guess
  echo "Guess the secret number between 1 and 1000:"
  read GUESS_NUMBER
  # test guess number
  # if not integer
  if ! [[ "$GUESS_NUMBER" =~ ^[0-9]+$ ]]
    then
    echo -e "\nThat is not an integer, guess again:"
    read GUESS_NUMBER
  fi
  while [[ $GUESS_NUMBER != $SECRET_NUMBER ]]
  do
  COUNT_TRY=$(($COUNT_TRY + 1))
  # if geater than secret number
  if [[ $GUESS_NUMBER -gt $SECRET_NUMBER ]]
  then
  echo -e "\nIt's lower than that, guess again:"
   # if lower than secret number
  else
  echo -e "\nIt's higher than that, guess again:"
  fi
  read GUESS_NUMBER
  done
  # if right number
  COUNT_TRY=$(($COUNT_TRY + 1))
  # get user id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name='$USER_NAME';")
  # insert game result
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id,try) VALUES($USER_ID,$COUNT_TRY);")
  # exit
  EXIT
}

# exit
EXIT(){
  echo -e "\nYou guessed it in $COUNT_TRY tries. The secret number was $SECRET_NUMBER. Nice job!"
}

MAIN_MENU