# Dotfiles

A small, public-safe collection of personal configuration files managed with
[GNU Stow](https://www.gnu.org/software/stow/).

## Install

Install GNU Stow first. On macOS with Homebrew:

```sh
brew install stow
```

Clone the repository and run the installer:

```sh
git clone <repository-url> ~/.dotfiles
cd ~/.dotfiles
./install
```

The installer creates individual symbolic links from the files under `home/`
to matching paths under `$HOME`. It can be run again after pulling changes.

Stow stops without overwriting anything when a destination already contains a
regular file. Review and move that file out of the way, then rerun `./install`.
Do not use `stow --adopt` unless you explicitly want existing destination
content to replace the repository version.

## Update

```sh
git pull
./install
```

Because the installed files are symbolic links, editing a managed file under
`$HOME` edits the repository copy directly.

## Remove links

From the repository root:

```sh
stow --dir=. --target="$HOME" --delete --no-folding home
```

This removes Stow-managed links without deleting the files in the repository.

## Add a configuration file

Place it under `home/` at the same relative path it should have under `$HOME`,
then rerun `./install`. Every file under `home/` is public and managed by Stow,
so review it for credentials, personal data, internal endpoints, histories, and
machine-specific state before committing it. GitHub Actions runs Gitleaks as an
additional safeguard.

The Neovim configuration is based on
[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), distributed under
the MIT license.
