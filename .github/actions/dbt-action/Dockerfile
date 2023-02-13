FROM python:3.9-slim

RUN echo "Using dbt adapter ${INPUT_ADAPTER}.${INPUT_VERSION}"

LABEL "maintainer"="Dat Nguyen <dat@infinitelambda.com>"
LABEL "com.github.actions.name"="Integration tests"
LABEL "com.github.actions.description"="Perform dbt package integration tests"
LABEL "com.github.actions.icon"="dbt"
LABEL "com.github.actions.color"="orange"

RUN pip install dbt-core==${INPUT_VERSION}.* --upgrade
RUN pip install dbt-${INPUT_ADAPTER}==${INPUT_VERSION} --upgrade

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]