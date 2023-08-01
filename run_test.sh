#!/bin/bash

# Show location of local install of dbt
echo $(which dbt)

# Show version and installed adapters
dbt --version

# Set the profile
cd integration_tests
cp ci/sample.profiles.yml profiles.yml
export DBT_PROFILES_DIR=.
export DBT_SCHEMA=${DBT_SCHEMA//./_}

# Show the location of the profiles directory and test the connection
dbt debug --target $1

# Select model to run (if any) e.g. `./run_test.sh snowflake +my_model`
_models=""
if [[ ! -z $2 ]]; then _models="--select $2"; fi

# Install dbt packages
dbt deps --target $1 || exit 1

YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Run the test
echo -e "${BLUE}1: Perform Failures intentionally inc Errors / w Fresh enviroment${NC}"
{ # try
  dbt build --select tag:failed --vars '{dq_tools_enable_store_test_results: true, fresh: true}' --target $1 $_models
} || { # catch
  echo -e "${YELLOW}Failed exit code: Intentional SKIP test failures${NC}"
}
dbt seed --target $1 $_models || exit 1

echo -e "${BLUE}2: Verify macros / Turn warns as errors${NC}"
dbt --warn-error build --exclude source:dq_tools_test+ tag:failed --vars '{dq_tools_enable_store_test_results: true}' --target $1 $_models || exit 1

echo -e "${BLUE}2: Enable & Verify models / Turn warns as errors${NC}"
dbt --warn-error build --select +tag:dq+ --exclude source:dq_tools_test --vars '{dq_tools_enable_store_test_results: true}' --target $1 $_models || exit 1

echo -e "${BLUE}3: Verify log table / Turn warns as errors${NC}"
dbt --warn-error test --select source:dq_tools_test --target $1 || exit 1