#!/bin/bash

as_user_enter_their_name_age(){
    echo Hello, what is your name ?
    read varname
    echo how old are you ?
    read varage
    echo It\'s nice to meet you: $varname, your age is $varage
}

as_for_user_account() {
    read -p 'Username: ' uservar
    read -sp 'Password: ' passvar
    echo
    echo Thankyou $uservar we now have your login details
}

read_multiple_input_a_time() {
    echo What cars do you like? Enter 3 value, ex: MER BMW Posche
    read car1 car2 car3
    echo Your first car was: $car1
    echo Your second car was: $car2
    echo Your third car was: $car3
}

as_user_enter_their_name_age
# as_for_user_account
# read_multiple_input_a_time
