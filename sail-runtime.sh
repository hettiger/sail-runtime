#!/bin/zsh

_SAIL_DIR="${${(%):-%x}:A:h}"

function sr() {
  setopt localoptions err_return

  git -C "$_SAIL_DIR" submodule update --init --recursive

  local VERSION="8.4"
  if [[ "$1" =~ ^[0-9]+\.[0-9]+$ ]]; then
    VERSION="$1"
    shift
  fi

  PHP_VERSION="$VERSION" \
  WWWGROUP="$(id -g)" \
  WWWUSER="$(id -u)" \
  docker compose \
    -f "$_SAIL_DIR/compose.yml" \
    run --build --rm \
    -v "$(pwd):/var/www/html" \
    app \
    bash -c 'source /setup.sh && exec "$@"' -- "${@:-bash}"
}
