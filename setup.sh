#!/bin/zsh

export PATH="$(composer global config bin-dir --absolute --quiet):$PATH"

composer global require laravel/installer
