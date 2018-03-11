#! /bin/bash

MYNAME=$(uname -n)
INPROD=$(perl -e 'print shift =~ /perl.space/ ? 1 : 0' $MYNAME)
if [ $INPROD == "1" ]; then
    csdb_home=/home/abeltje/CoreSmokeDB
    csdb_env=smokedb
else
    this_dir=$(dirname $0)
    csdb_home=$(perl -MCwd=abs_path -e 'print abs_path shift' $this_dir)
    csdb_env=test
fi

cd $csdb_home

if [ $INPROD  == "1" ] ; then
#    git pull --all
    PERL5LIB=../perl5/lib/perl5/
fi

export PERL5LIB="$csdb_home/lib:$PERL5LIB"
plackup --server Starman ./tsgateway -E "$csdb_env" --max-requests 10 --workers 3
