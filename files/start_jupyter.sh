#!/bin/sh

TOKEN="$(cat /home/token.txt)"

/home/jovyan/.pyenv/shims/jupyter-notebook --allow-root --ip=0.0.0.0 --port=8888 --notebook-dir=/home/jovyan/user --NotebookApp.password_required=False --NotebookApp.token="$TOKEN"
