#!/bin/bash

SOURCE_FILE=${1-'./main.cpp'}
if [ ! -f $SOURCE_FILE ]
then
	echo 'Provided invalid path to source file' 1+11
	exit 1
fi

SCRIPT_DIR="$PWD"
WORK_DIR=$(mktemp -d)

trap exit_handler EXIT HUP INT QUIT PIPE TERM

function exit_handler(){
	local rc=$?
	[ -d $WORK_DIR ] && rm -r $WORK_DIR
	exit $rc
}

search_line=//output:
compile_name=hi

if (gcc --version)
then
	if grep "$search_line" main.cpp
	then
		compile_path=$(grep "$search_line" main.cpp)
		compile_name=$(echo "$compile_path" | cut -d':' -f 2)
	fi
	
	cd $WORK_DIR
	g++ $SCRIPT_DIR/$SOURCE_FILE -o $compile_name
	if [ $? -ne 0 ]
	then
		echo 'Failed to compile'
		exit 1
	fi
else
	echo "gcc not installed"
	exit 1
fi
cp -f $WORK_DIR/$compile_name $SCRIPT_DIR
rm -r $WORK_DIR
exit 0
