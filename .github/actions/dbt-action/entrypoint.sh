#!/bin/sh
set -e

echo "INFO: dbt project folder set as: \"$2\""
cd $2

echo "INFO: dbt profile folder set as: \"$3\""
export DBT_PROFILES_DIR=$3

echo "INFO: dbt command used as: $1"

$1
if [ $? -eq 0 ]
  then
    echo "DBT_RUN_STATE=passed" >> $GITHUB_ENV
    echo "result=passed" >> $GITHUB_OUTPUT
  else
    echo "DBT_RUN_STATE=failed" >> $GITHUB_ENV
    echo "result=failed" >> $GITHUB_OUTPUT
    exit 1
fi