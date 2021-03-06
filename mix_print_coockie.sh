#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/mix_print_coockie.sh && bash mix_print_coockie.sh ;
# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/mix_print_coockie.sh && bash mix_print_coockie.sh google.com ;

# check sqlite3 installed
pkg=sqlite3
if [[ -z $(dpkg --get-selections | awk '{print $1}' | grep -x $pkg ) ]]; then
    sudo echo
    sudo apt install sqlite3
fi

# coockie path
CHROME="${HOME}/.config/google-chrome/Default"
COOKIES="$CHROME/Cookies"

# query
# QUERY='select * from cookies'
QUERY='select host_key, path, expires_utc, name, encrypted_value from cookies'

# coloums
# creation_utc INTEGER NOT NULL
# host_key TEXT NOT NULL
# name TEXT NOT NULL
# value TEXT NOT NULL
# path TEXT NOT NULL
# expires_utc INTEGER NOT NULL
# is_secure INTEGER NOT NULL
# is_httponly INTEGER NOT NULL
# last_access_utc INTEGER NOT NULL
# has_expires INTEGER NOT NULL DEFAULT 1
# is_persistent INTEGER NOT NULL DEFAULT 1
# priority INTEGER NOT NULL DEFAULT 1
# encrypted_value BLOB DEFAULT ''
# samesite INTEGER NOT NULL DEFAULT -1

# query where
if [[ $# == 1 ]]; then
    domain=$1
    QUERY="$QUERY where host_key like '$domain'"
fi

# print result
sqlite3 -separator '    ' "${COOKIES:-Cookies}" "$QUERY"
