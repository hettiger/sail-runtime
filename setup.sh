#!/bin/zsh

export PATH="$(composer global config bin-dir --absolute --quiet):$PATH"

composer global require laravel/installer

export NVM_DIR="$HOME/.nvm"

if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  git -c advice.detachedHead=false clone --quiet --depth 1 --branch v0.40.3 https://github.com/nvm-sh/nvm.git "$NVM_DIR" || return 1
fi

# --no-use keeps the PATH set by the .nvmrc activation below; the nvm
# installer's default profile lines would re-activate the "default" alias
# on every shell start and override it.
if ! grep -qs 'sail-runtime nvm' "$HOME/.bashrc"; then
  cat >> "$HOME/.bashrc" << 'EOF'

# sail-runtime nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" --no-use
EOF
fi

source "$NVM_DIR/nvm.sh" --no-use || return 1

if [[ -f .nvmrc ]]; then
  nvm use || nvm install || return 1

  if command -v corepack > /dev/null 2>&1; then
    if ! corepack enable 2>/dev/null; then
      echo "warning: 'corepack enable' failed; packageManager pins in package.json will not be honored" >&2
    fi
  else
    echo "warning: corepack not found; packageManager pins in package.json will not be honored" >&2
  fi
fi
