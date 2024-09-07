# --
# Configures the default Git command
GIT?=git

# --
# Configures the default version of Python
PYTHON_VERSION?=3.12
PYTHON?=python$(PYTHON_VERSION)

# --
# Configures the version of the NodeJS command.
NODE_VERSION?=22
# --
# Configures the `node` command alias.
NODE?=node$(if $(NODE_VERSION),-$(NODE_VERSION))

# --
# Configures the `npm` command alias.
NPM?=npm$(if $(NODE_VERSION),-$(NODE_VERSION))

# EOF
