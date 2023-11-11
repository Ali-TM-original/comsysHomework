#!/bin/bash

# If the files do not exist we display a red erro message and exit out
if [ ! -f teams.dat ] || [ ! -f students.dat ]; then
	echo -e "\e[31mData Files (teams.dat) and (students.dat) NOT FOUND. Make sure they exist in the same directory\e[0m"
	exit 1
fi

# Have a function for printing out a beautiful help message

ExtraArg="$2"

HelpUtil(){
	echo "Description of the script here"
	echo
	echo "Syntax: [-list | -student | -max | -h ]"
	echo "                                Options"
	echo "-------------------------------------------------------------------------"
	echo "| Command    | parameter    | Usage                                     |"
	echo "|-----------------------------------------------------------------------|"
	echo "| -h         |              | Displays this help message                |"
	echo "| -list      | teacher name | Lists names of course belonging to teacher|"
	echo "| -student   | student name | Lists teachers who teach the student      |"
	echo "| -max       |              | Prints name of teacher with most courses  |"
	echo "------------------------------------------------------------------------ "
}

# HELPER FUNCTION FOR -LIST COMMAND
ListFunc(){
	if [[ -z $ExtraArg  ]]; then
		echo "Missing Argument Teacher Name"
		exit 1
	fi
	
	local File="teams.dat"
	courses=""
	
	while IFS="," read -r Course TeamsCode Teacher; do
		# I don't know why this exists and how in the world I found it
		# But Echoing a string with spaces removes spaces lmao

		if [[ `echo $Teacher` = `echo $ExtraArg` ]]; then
			courses+="| $Course "
		fi
	done < $File

	echo $courses

}

# HELPER FUNCTION FOR -MAX COMMAND
MaxFunc(){

	local File="./teams.dat"
	
	greatest=""
	count=0

	while IFS="," read -r Course TeamsCode Teacher; do
		counter=`grep -o "$Teacher" $File | wc -l`
		if [[ $counter -ge $count ]]; then
			greatest="$Teacher"
			count="$counter"
		fi
	done < $File

	echo $greatest

}

studentFunc(){
	if [[ -z $1 ]];then
		echo "Missing Argument Student Name"
		exit 1
	fi

	teams=($(grep "$1" ./students.dat | cut -d "," -f 2-))
	finalTeach=""
	while IFS="," read -r ClassNAme Code TeacherName; do
		for tm in "${teams[@]}"; do
			cleansedcode=`echo $tm | tr -d ","`
			if [[ `echo $cleansedcode` == `echo $Code` ]]; then
				finalTeach+="| $TeacherName"
			fi
		done
	done < "./teams.dat"

	echo "Teachers that teach $1 are"
	echo $finalTeach

}


# This is where we check each of our cases
if [ $# -gt 0 ]; then
	case $1 in
		-list)
			ListFunc
			exit 1
			;;
		-student)
			studentFunc "$2"
			exit 1
			;;
		-max)
			MaxFunc
			exit 1
			;;
	*)
	HelpUtil
	exit 1
	;;

esac
fi

# Come here to display our beautiful help command
HelpUtil
