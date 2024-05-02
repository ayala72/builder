#!/bin/bash

PROGRAM="$(basename "$0")"

name=""
file=

HelpUsage() {
    echo -e "Usage: builder <file>
    [-n | --name]:      Names the compiled file. (Default: file name)
    [-c | --compiler]:  Set the compiler. (Default: g++)"
}

SetName() {
    if [ -z "$1" ]; then
        >&2 echo "(ERROR)[$PROGRAM]: No file name given"
        exit 1
    fi

    if [ -z "$name" ]; then
        name="${1%.*}"
    fi
}

BuildFile() {
    SetName "$(basename "$file")"

    compiler="/usr/bin/g++"

    if ! [ -e "$compiler" ]; then
        >&2 echo "(ERROR)[$PROGRAM]: No compiler found. $compiler"
        exit 1;
    else
        echo "[$PROGRAM]: Compiler found"
        file "$compiler"
    fi

    echo "[$PROGRAM]: Building source file..."
    status=$("$compiler" -fdiagnostics-color=always -g "$file" -o "$name")$?
    
    if [ "$status" == 0 ]; then
        echo "[$PROGRAM]: Build successful!"
    else
        >&2 echo "(ERROR)[$PROGRAM]: Compiling error has occured..."
        exit "$status";
    fi
}   

if [ -e "$1" ]; then
    case "$1" in
        *.cpp ) 
        echo "[$PROGRAM]: C++ source file found!";;

        *)
        >&2 echo "(ERROR) [$PROGRAM]: Not a valid file"
        exit 1;;
    esac

    file="$1"
    shift
fi

while [[ -n $1 ]]; do
    case "$1" in
        -n | --name ) 
        shift
        SetName "$1";;

        -h | --help ) 
        HelpUsage
        exit 0;;

        *) 
        >&2 echo -e "$PROGRAM: quick command wrapper for g++
        Use $PROGRAM [-h | --help] for options."
        exit 1;;
    esac

    shift
done

BuildFile