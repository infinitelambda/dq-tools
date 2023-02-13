ARG DBT_ADAPTER
ARG DBT_VERSION
FROM python:3.9-slim

RUN echo "Using dbt adapter ${DBT_ADAPTER}.${DBT_VERSION}"

LABEL "maintainer"="Dat Nguyen <dat@infinitelambda.com>"
LABEL "com.github.actions.name"="Integration tests"
LABEL "com.github.actions.description"="Perform dbt package integration tests"
LABEL "com.github.actions.icon"="dbt"
LABEL "com.github.actions.color"="orange"

RUN pip install dbt-core==${DBT_VERSION}.* --upgrade
RUN pip install dbt-${DBT_ADAPTER}==${DBT_VERSION} --upgrade

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]