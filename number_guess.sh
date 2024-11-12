#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo Enter your username: 
read USERNAME

USER=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")

if [[ -z $USER ]]
then
  echo Welcome, $USERNAME! It looks like this is your first time here.
else
  while IFS='|' read NAME GAMES BEST
  do
    echo Welcome back, $NAME! You have played $GAMES games, and your best game took $BEST guesses.
  done < <($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")
fi


NUM=$(( (RANDOM % 1000) + 1 ))
echo Guess the secret number between 1 and 1000:

GUESS=0
TIMES=0

while [[ $NUM != $GUESS ||  ! ($GUESS =~ ^[0-9]+$) ]]
do
  read GUESS

  if [[ ! ($GUESS =~ ^[0-9]+$) ]]
  then
    echo That is not an integer, guess again:
  else
    TIMES=$(( TIMES + 1 ))
    if (( GUESS < NUM ))
    then
      echo "It's higher than that, guess again:"
    else if (( GUESS > NUM ))
    then
      echo "It's lower than that, guess again:"
    else
      echo "You guessed it in $TIMES tries. The secret number was $NUM. Nice job!"

      USER=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")

      if [[ -z $USER ]]
      then
        ADD_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
      fi

      while IFS='|' read NAME GAMES BEST
      do
        GAMES=$(( GAMES + 1 ))

        ADD=$($PSQL "UPDATE users SET games = $GAMES WHERE username = '$USERNAME'")

        if [[ -z "$BEST" ]]
        then
          ADD=$($PSQL "UPDATE users SET best = $TIMES WHERE username = '$USERNAME'")
        else
          if [[ $BEST > $TIMES ]]
          then
            ADD=$($PSQL "UPDATE users SET best = $TIMES WHERE username = '$USERNAME'")
          fi
        fi
      done < <($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")
    fi
    fi
  fi
done