#!/usr/bin/env bash

LINK=$(readlink $0)
if [ "$LINK" != "" ]; then
    LINKDIR=$(cd $(dirname $0) && pwd)
    PROGRAM="$LINKDIR/$LINK"
else
    PROGRAM=$0
fi
MYDIR=$(cd $(dirname $PROGRAM) && pwd)

#cli testdir pattern reportdir REPORTERS
if [ $# -lt 3 ]; then
    echo "$(basename $0) TESTDIR PATTERN REPORTDIR [REPORTERS]" >&2
    echo "Example: " >&2
    echo "$(basename $0) ./specs *.test.js ./reports default coverage xunit" >&2
    exit 1
fi

PROJECTDIR=$(cd $(npm bin)/../..  && pwd)
TESTDIR="$PROJECTDIR/$1"
PATTERN="$2"
REPORTDIR="$PROJECTDIR/$3"
shift
shift
shift

DOCOVERAGE=0
EMITDEFAULT=0
REPORTERS=( )
for var in "$@"
do
    if [ "$var" == "coverage" ]; then
        DOCOVERAGE=1
    elif [ "$var" == "default" ]; then
        EMITDEFAULT=1
    else
        REPORTERS+=( $var )
    fi
done

NYCLOCAL=$(npm bin)/nyc
NYCGLOBAL=$(which nyc)

if [ $DOCOVERAGE -eq 0 ]; then
    CMD="node"
elif [ -e "$NYCLOCAL" ]; then
    CMD="$NYCLOCAL -s --report-dir \"$REPORTDIR\" "
elif [ "$NYCGLOBAL" != "" ]; then
    CMD="$NYCGLOBAL -s --report-dir \"$REPORTDIR\" "
else
    echo "nyc not found" >&2
    exit 1
fi

CHILOCAL=$(npm bin)/runsuite
CHIGLOBAL=$(which runsuite)

#Run chihuahua
if [ -e "$CHILOCAL" ]; then
    CHIRUN="$CHILOCAL"
elif [ "$CHIGLOBAL" != "" ]; then
    CHIRUN="$CHIGLOBAL"
else
    echo "chihuahua is missing" >&2
    exit 1
fi

if [ $EMITDEFAULT -eq 0 ]; then
    DEFRPTOPT="--console-output=false"
else
    DEFRPTOPT="--console-output=true"
fi

mkdir -p "$REPORTDIR"

#This will store the default report
find "$TESTDIR" -name $PATTERN \
    | $CMD $CHIRUN "--output-dir=$REPORTDIR" "$DEFRPTOPT"

RC=$?


if [ $RC == 126 ]; then
    exit $RC
fi

TOKENS=( $CMD )
NODECMD="${TOKENS[0]}"
NODECMDNAME=$(basename "$NODECMD")

#If we ran NYC
if [ "$NODECMDNAME" = "nyc" ]; then
    $NODECMD report
fi

for var in "${REPORTERS[@]}"
do
    #If it starts with +, then print it to the console.
    if [ ${var:0:1} == "+" ]; then
        REPORTER=${var:1}
        $MYDIR/reporters/$REPORTER "$REPORTDIR/testresults.json"
    else
        REPORTER=$var
        set -e
        $MYDIR/reporters/$REPORTER "$REPORTDIR/testresults.json" > /dev/null
        $MYDIR/reporters/$REPORTER "$REPORTDIR/testresults.json" > "$REPORTDIR/${REPORTER}.txt"
    fi
done

exit $RC