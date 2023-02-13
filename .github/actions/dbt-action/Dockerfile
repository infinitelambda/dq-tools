ARG DBT_ADAPTER="dbt-snowflake:1.2.latest"
FROM ghcr.io/dbt-labs/${DBT_ADAPTER}

LABEL "maintainer"="Dat Nguyen <dat@infinitelambda.com>"
LABEL "com.github.actions.name"="Integration tests"
LABEL "com.github.actions.description"="Perform dbt package integration tests"
LABEL "com.github.actions.icon"="dbt"
LABEL "com.github.actions.color"="orange"

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]