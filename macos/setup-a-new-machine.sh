#!/bin/bash

git submodule update --init --recursive

git submodule update --recursive --remote


sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
