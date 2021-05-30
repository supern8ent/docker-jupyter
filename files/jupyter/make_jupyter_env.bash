#!/bin/bash

eval "$($HOME/.pyenv/bin/pyenv init --path)"
$HOME/.pyenv/bin/pyenv global 3.8.10
cd $HOME/.environments/jupyter
$HOME/.poetry/bin/poetry config virtualenvs.in-project true
$HOME/.poetry/bin/poetry install
