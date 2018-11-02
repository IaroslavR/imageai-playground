#!/usr/bin/env bash
PORT=8888
IP=127.0.0.1
VENV=`${HOME}/.local/bin/pipenv --venv`
${VENV}/bin/python ${VENV}/bin/jupyter-notebook --no-browser --ip ${IP} --port ${PORT} --port-retries=0
