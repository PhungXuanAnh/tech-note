#!/bin/bash

multiple-condition-1() {
    a=10
    b=20

    if [ $a == $b ]
    then
        echo "a is equal to b"
    elif [ $a -gt $b ]
    then
        echo "a is greater than b"
    elif [ $a -lt $b ]
    then
        echo "a is less than b"
    else
        echo "None of the condition met"
    fi
}

multiple-condition-2() {
    echo -n "Enter the first number: "
    read VAR1
    echo -n "Enter the second number: "
    read VAR2
    echo -n "Enter the third number: "
    read VAR3

    if [[ $VAR1 -ge $VAR2 ]] && [[ $VAR1 -ge $VAR3 ]]
    then
        echo "$VAR1 is the largest number."
    elif [[ $VAR2 -ge $VAR1 ]] && [[ $VAR2 -ge $VAR3 ]]
    then
        echo "$VAR2 is the largest number."
    else
        echo "$VAR3 is the largest number."
    fi
}

nested-if-else() {
    echo -n "Enter the first number: "
    read VAR1
    echo -n "Enter the second number: "
    read VAR2
    echo -n "Enter the third number: "
    read VAR3

    if [[ $VAR1 -ge $VAR2 ]]
    then
        if [[ $VAR1 -ge $VAR3 ]]
        then
            echo "$VAR1 is the largest number."
        else
            echo "$VAR3 is the largest number."
        fi
    else
        if [[ $VAR2 -ge $VAR3 ]]
        then
            echo "$VAR2 is the largest number."
        else
            echo "$VAR3 is the largest number."
        fi
    fi
}

# multiple-condition-1
# multiple-condition-2
nested-if-else
