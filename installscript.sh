#!/bin/bash

if [ "$EUID" -ne "0" ]
then
	echo "Please run as root"
	exit
else
	echo "I am root"
	exit
fi
