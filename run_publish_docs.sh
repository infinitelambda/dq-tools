#!/bin/bash

# Show location of local install of dbt
echo $(which dbt)

# Show version and installed adapters
dbt --version

# Set the profile
cd integration_tests
cp ci/sample.profiles.yml profiles.yml
export DBT_PROFILES_DIR=.

# Install dbt packages
dbt deps --target $1 || exit 1

YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Run the build
echo -e "${BLUE}1: Build docs${NC}"
echo '{% docs __overview__ %}' >> ./models/overview.md
echo '_Generated at: $GENERATED_TIMESTAMP_' >> ./models/overview.md
cat ../README.md >> ./models/overview.md
sed -i "s/'{{/'{{\"{{\"}}/g" ./models/overview.md # escape {{}} because of jinja parsing
sed -i "s/}}'/{{\"}}\"}}'/g" ./models/overview.md # escape {{}} because of jinja parsing
sed -i "s/\$GENERATED_TIMESTAMP/$(date -u)/g" ./models/overview.md
echo '{% enddocs %}' >> ./models/overview.md
dbt docs generate --target $1 || exit 1

# Publish aws
echo -e "${BLUE}2: Publish docs to S3${NC}"
aws s3 cp ./target/index.html s3://dq-tools-docs/latest/index.html || exit 1
aws s3 cp ./target/catalog.json s3://dq-tools-docs/latest/catalog.json || exit 1
aws s3 cp ./target/manifest.json s3://dq-tools-docs/latest/manifest.json || exit 1
aws s3 cp ./target/run_results.json s3://dq-tools-docs/latest/run_results.json || exit 1
aws s3 cp ./target/graph.gpickle s3://dq-tools-docs/latest/graph.gpickle || exit 1
aws s3 cp ./README.md s3://dq-tools-docs/latest/integration_tests/README.md || exit 1
aws s3 cp ../assets s3://dq-tools-docs/latest/assets/ --recursive || exit 1