#!/usr/bin/env bash
PORT=${PORT:-11888}
IP=${IP:-"127.0.0.1"}
VENV=`${HOME}/.local/bin/pipenv --venv`
${VENV}/bin/python ${VENV}/bin/jupyter-notebook --no-browser --ip ${IP} --port ${PORT} --port-retries=0
