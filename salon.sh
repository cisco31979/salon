#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\n~~~~~ MY SALON ~~~~~\n"

  echo -e "Welcome to My Salon, how can I help you?\n"

  SERVICES_MENU
}
 
SERVICES_MENU() {
  # get services offered
  SERVICES_OFFERED=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # display services
  echo "$SERVICES_OFFERED" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # get service requested
  read SERVICE_ID_SELECTED

  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "This is not a valid number"
  else
    # get service selected
    SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    # if not available
    if [[ -z $SERVICE_AVAILABILITY ]]
    then
      # send to main menu
      echo -e "\nI could not find that service. What would you like today?\n"
      SERVICES_MENU
    else
      # get customer info
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # if customer doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # get new customer name
        echo -e "\nThere is no record for that phone number, what's your name?"
        read CUSTOMER_NAME

        # insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
      fi
      # get service requested
      SERVICE_REQUESTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    
      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # get time of appointment
      echo -e "\nWhat time would you like your $(echo $SERVICE_REQUESTED | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
      read SERVICE_TIME

      # insert service request
      INSERT_SERVICE_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      #send to main menu
      echo -e "\nI have put you down for a $(echo $SERVICE_REQUESTED | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g').\n"
      EXIT 
    fi
  fi
}

EXIT() {
  echo -e "Thank you for stopping in.\n"
}
MAIN_MENU