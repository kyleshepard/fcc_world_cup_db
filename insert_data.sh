#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# truncate all data before inserting in test mode
if [[ $1 == "test" ]]
then
  echo $($PSQL "TRUNCATE teams, games")
fi

cat games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals
do
  # skip first line
  if [[ $year == "year" ]]
  then
    continue
  fi

  # get winner id
  winner_id=$($PSQL "SELECT team_id FROM teams where name='$winner';")
  # if team does not already exist
  if [[ -z "$winner_id" ]]
  then
    # create the team
    insert_winner_result=$($PSQL "insert into teams(name) values('$winner');")
    # get the newly-created team id
    winner_id=$($PSQL "SELECT team_id FROM teams where name='$winner';")
  fi

  # get opponent id
  opponent_id=$($PSQL "SELECT team_id FROM teams where name='$opponent';")
  # if team does not already exist
  if [[ -z "$opponent_id" ]]
  then
    # create the team
    insert_opponent_result=$($PSQL "insert into teams(name) values('$opponent');")
    # get the newly-created team id
    opponent_id=$($PSQL "SELECT team_id FROM teams where name='$opponent';")
  fi

  # insert game
  insert_game_result=$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);")
  
done
