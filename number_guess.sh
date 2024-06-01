#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#randomly generate a target number for user to guess
GENERATE_RAND_NUM() {
  RAND_NUM=$((RANDOM % 1000 + 1))
  #echo for testing purposes only
  #echo $RAND_NUM
}

MAIN() {

  #get user, test validity and history, give appropriate welcome message
  echo "Enter your username:" 
  read USERNAME
  #username will be varchar(22)
  #if USERNAME larger than 22, solicit again
  if [[ ${#USERNAME} -gt 22 ]]
  then
    echo "Maximum username length is 22, please input a shorter name."
  else
    #get username, games_played, best_game from number_guess database
    USER_HISTORY=$($PSQL "SELECT games_played, best_game FROM number_guess WHERE username = '$USERNAME'")
    #if empty
    if [[ -z $USER_HISTORY ]]
    #then echo Welcome/first time message
    then
      echo "Welcome, $USERNAME! It looks like this is your first time here."
    #else echo Welcome/recap message
    else
      IFS="|" read GAMES_PLAYED BEST_GAME <<< $USER_HISTORY
      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    fi
  fi

  #echo "best_game is $BEST_GAME"

  #first, generate a random number
  GENERATE_RAND_NUM
  #test echo
  #echo "[DEBUG]: RAND_NUM is $RAND_NUM"

  #start the counter
  COUNT_OF_GUESSES=0
  #echo "[DEBUG]: Guess count is $COUNT_OF_GUESSES."

  #prompt very first guess from user
  echo "Guess the secret number between 1 and 1000:"
  #read CURRENT_GUESS

  #UNTIL GAME OVER
  until [[ $CURRENT_GUESS -eq $RAND_NUM ]]
  do
    #SOLICIT GUESS - there should always be a prompt echo before this
    read CURRENT_GUESS
    #CHECK GUESS
    #HANDLE_GUESS $COUNT_OF_GUESSES $RAND_NUM $CURRENT_GUESS
    #echo "[DEBUG] In handle_guess count-of-guesses is $COUNT_OF_GUESSES, TARGET is $RAND_NUM, CURRENT_GUESS is $CURRENT_GUESS"
    #[[ $RAND_NUM -eq $CURRENT_GUESS ]]; echo $?
    #if guess is not an integer
    if [[ ! $CURRENT_GUESS =~ ^[0-9]+$ ]]
    #then prompt for correction
    then
      echo "That is not an integer, guess again:"
    #valid guesses return statement and increment guess counter
    elif [[ $CURRENT_GUESS < $RAND_NUM ]]
    then
      COUNT_OF_GUESSES=$((COUNT_OF_GUESSES + 1))
      echo "It's higher than that, guess again:"
    elif [[ $CURRENT_GUESS > $RAND_NUM ]]
    then
      COUNT_OF_GUESSES=$((COUNT_OF_GUESSES + 1))
      echo "It's lower than that, guess again:"
    elif [[ $CURRENT_GUESS == $RAND_NUM ]]
    then
      COUNT_OF_GUESSES=$((COUNT_OF_GUESSES + 1))
      echo "You guessed it in $COUNT_OF_GUESSES tries. The secret number was $RAND_NUM. Nice job!"
    fi
  #END UNTIL (GAME FINISHED)
  done


  #LOG VARIABLES TO DATABASE
  #if first-time user
  if [[ -z $USER_HISTORY ]]
  #then add entirety to database
  then
    NEW_USER_INSERT_RESULT=$($PSQL "INSERT INTO number_guess(username,games_played,best_game) VALUES('$USERNAME',1,$COUNT_OF_GUESSES)")
  else
    #INCREMENT USER'S GAME COUNT BY ONE
    GAMES_PLAYED=$((GAMES_PLAYED + 1))
    #DETERMINE IF THIS WAS A BEST GAME, UPDATE BEST_GAME VAR ACCORDINGLY
    #echo "[DEBUG] BEST_GAME is $BEST_GAME"
    if [[ $COUNT_OF_GUESSES -lt $BEST_GAME ]]
    then
      #echo "[DEBUG] new best game"
      BEST_GAME=$COUNT_OF_GUESSES
      #echo "[DEBUG] $BEST_GAME"
    fi
    EXISTING_USER_INSERT_RESULT=$($PSQL "UPDATE number_guess SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")
  fi
  

  
}

#maybe needs separate function for guessing, passing in target and attemps so far

#running script means running main
MAIN

#for testing only
#GENERATE_RAND_NUM
