GIT?=git ## Alias to Git

PYTHON_VERSION?=3.12  ## Current Python version
PYTHON?=python$(PYTHON_VERSION) ## Python interpreter

NODE_VERSION?=22 ## Default NodeJS version
NODE?=node$(if $(NODE_VERSION),-$(NODE_VERSION)) ## Node command alias

NPM?=npm$(if $(NODE_VERSION),-$(NODE_VERSION)) ## NPM command alias


NO_INTERACTIVE?=## Forces non-interactive mode
NO_COLOR?=## Removes color output
# EOF
