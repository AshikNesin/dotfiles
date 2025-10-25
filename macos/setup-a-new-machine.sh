#!/bin/bash

git submodule update --init --recursive

git submodule update --recursive --remote

# Install pre-commit framework for Gitleaks
if ! command -v pre-commit &> /dev/null; then
    echo "Installing pre-commit framework..."
    pip install pre-commit
fi

# Install pre-commit hooks
echo "Setting up pre-commit hooks..."
pre-commit install

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
