#!/bin/bash

# Realm dir path
# path=$(echo $PWD) # For testing
path=/c/helm/helmfiledemo/shell/ # Use in rundeck instance

echo "Path: $path";

if [ -z $1 ]
then
    echo "An action is required. [add/remove/list]."
    exit 1;
else
    action=$1
fi

if [[ ( -z $2  || $2 == 'admin' ) && $1 != 'list' ]]
then
    echo $1
    echo "A username is required as first arg. ( Note: The admin user can't be modified )"
    exit 1;
else
    username=$2
fi

if [[ -z $3 && $1 != 'list' && $1 != 'remove' ]]
then
    echo "A password is required as first arg. ( Note: The admin user can't be modified )"
    exit 1;
else
    password=$3
fi

if [[ -z $4 && $1 == 'add' ]]
then
    echo "Please mentione the privileges for this user. ( The privileges must be seperated by comma wothout any spaces )"
    exit 1;
else
    previlages=$4
fi


list()
{
    usernames=$(cat $path/realm.properties | sed "s/:/,/g" | cut -d, -f 1,4-10 | sed "s/,/ : Permissions => /" |sort)
    IFS=' '
    read -r -a username <<< clear
    echo $usernames;
}

function add() {
    remove $username
    MD5=$(echo -n $password | md5sum)
    read -r -a MD5 <<< "$MD5"
    userCred="${username}: MD5:${MD5[0]},$previlages"
    USER_VAR=`cat $path/realm.properties | grep  "$username" | cut -d: -f1`
    if  [ "$USER_VAR" = "$username" ]
    then
    echo "user already exists $username"
    #sudo cat <<EOT >> $path/realm.properties
    else
    cat <<EOT >> $path/realm.properties
$userCred
EOT
    echo "User $username has created/updated"
    fi
}


function remove() {
    #lineNumber=$(cat $path/realm.properties | grep -n "$username:" | cut -d: -f1)
    USER_VAR=`cat $path/realm.properties | grep  "$username" | cut -d: -f1`
    #if [ $lineNumber ]
    if  [ -z "$USER_VAR" ]
    then
        #lastLine=$((lineNumber+1))
        #sudo sed -i -e "${lineNumber},${lineNumber}d" $path/realm.properties
        #sed -i -e "${lineNumber},${lineNumber}d" $path/realm.properties
        echo "User $username exists."
    else
        echo "User $username doesn't exist."
    fi
}

function note() {
    echo "*********"
    echo "*********"
    echo "To apply the changes, the Rundeck service needs to be restarted."
    echo "The ideal time for this action is on Tuesday between 1 PM to 2 PM"
    echo "*********"

}

case $action
in
    list)
        list
        ;;
    add)
        add
        list
        note
        ;;
    remove)
        remove
        list
        note
        ;;
    *) echo "The action is not valid." ;;
esac
