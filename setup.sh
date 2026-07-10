#!/bin/zsh

export PATH="$(composer global config bin-dir --absolute --quiet):$PATH"

composer global require laravel/installer

if [[ -f .nvmrc ]]; then
  export NVM_DIR="$HOME/.nvm"

  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE=/dev/null bash || return 1
  fi

  source "$NVM_DIR/nvm.sh" --no-use || return 1
  nvm use || nvm install || return 1

  if command -v corepack > /dev/null; then
    corepack enable || return 1
  fi
fi
