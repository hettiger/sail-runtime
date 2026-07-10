# Sail Runtime

Run any directory inside a [Laravel Sail](https://laravel.com/docs/sail) container — as an interactive shell or a one-off command — without installing PHP or Composer on your machine.

The official [`laravel/sail`](https://github.com/laravel/sail) runtimes are pulled in as a git submodule, so the containers are built from the exact same Dockerfiles Sail itself uses.

## Requirements

- Docker (with the Compose plugin)
- zsh
- git

## Installation

Clone the repository and source `sail-runtime.sh` from your `.zshrc`:

```sh
git clone git@gitlab.main-echo.de:main-netz/docker/sail-runtime.git
echo "\nsource $(pwd)/sail-runtime/sail-runtime.sh" >> ~/.zshrc
```

There is no need to clone with `--recurse-submodules` — the `sr` function initializes and updates the submodule automatically on every run.

## Usage

Run `sr` from any directory. It mounts the current working directory to `/var/www/html` in a fresh container and removes the container once the command exits.

```sh
sr                  # interactive bash, PHP 8.4 (default)
sr 8.3              # interactive bash, PHP 8.3
sr php -v           # run a one-off command
sr 8.2 laravel new  # combine PHP version and command
```

If the first argument looks like a version number (e.g. `8.3`), it selects the PHP runtime; all remaining arguments are executed inside the container. Without arguments you get an interactive `bash`.

### PHP versions

Any version that ships a runtime in `laravel/sail` is supported — currently `8.0` through `8.5`. The default is `8.4`.

### Node versions

The Sail runtimes ship a fixed Node version. If the mounted directory contains a `.nvmrc`, `setup.sh` activates the requested version via [nvm](https://github.com/nvm-sh/nvm) on startup — resolved exactly like on your host. Missing versions are downloaded once and cached; if activation fails (e.g. first download while offline, or an invalid `.nvmrc`), `sr` aborts instead of silently running the wrong Node. Without a `.nvmrc` you get the Node version baked into the Sail image. After activation, `corepack enable` runs so `packageManager` pins in `package.json` are honored.

## How it works

- `compose.yml` defines a single `app` service built from `laravel/sail/runtimes/<version>`.
- Containers are ephemeral (`docker compose run --build --rm`); nothing persists between runs except the files in your mounted directory and the `sail` user's home.
- The home directory lives in the `sail-runtime-home` named volume (shared across all PHP versions), so Composer, npm, and nvm caches survive between runs. `docker volume rm sail-runtime-home` resets it.
- Commands run with your host UID/GID, so files created inside the container belong to you.
- On startup, `setup.sh` installs the [Laravel installer](https://github.com/laravel/installer) globally, making `laravel new` available out of the box, and activates the `.nvmrc` Node version if present.
