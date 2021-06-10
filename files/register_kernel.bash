#!/bin/bash

# 1st argument: python version to ask pyenv to use (must have already been installed)
# 2nd argument: name of the directory into of the poetry environment

eval "$($HOME/.pyenv/bin/pyenv init --path)"
$HOME/.pyenv/bin/pyenv global $1
cd $HOME/.environments/$2
$HOME/.poetry/bin/poetry run python -m ipykernel install --user --name Py38a --display-name "Py38a"
