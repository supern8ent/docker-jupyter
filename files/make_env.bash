#!/bin/bash

# 1st argument: python version to ask pyenv to use (must have already been installed)
# 2nd argument: name of the directory into of the poetry environment

eval "$($HOME/.pyenv/bin/pyenv init --path)"
$HOME/.pyenv/bin/pyenv global $1
cd $HOME/.environments/$2
$HOME/.poetry/bin/poetry config virtualenvs.in-project true
$HOME/.poetry/bin/poetry install --no-interaction --no-ansi
