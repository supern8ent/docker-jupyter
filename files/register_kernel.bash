#!/bin/bash

# 1st argument: python version to ask pyenv to use (must have already been installed)
# 2nd argument: name of the directory of the poetry environment
# 3rd argument: ipython internal name of the environment
# 4th argument: display name of the environment

eval "$($HOME/.pyenv/bin/pyenv init --path)"
$HOME/.pyenv/bin/pyenv global $1
cd $HOME/.environments/$2
$HOME/.poetry/bin/poetry run python -m ipykernel install --user --name $3 --display-name "$4"
