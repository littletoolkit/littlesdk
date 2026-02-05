# -----------------------------------------------------------------------------
#
# MISE MODULE CONFIGURATION
#
# -----------------------------------------------------------------------------

# Configuration for mise tool management.
# Mise is a polyglot tool version manager.

# -----------------------------------------------------------------------------
#
# MISE SETTINGS
#
# -----------------------------------------------------------------------------

# --
# ## Debug and Output

# Enable mise debug output
MISE_DEBUG?=0 ## Enable mise debug mode (0 or 1)

# Enable quiet mode for mise
MISE_QUIET?=0 ## Enable mise quiet mode (0 or 1)

# --
# ## Version and Path

# Mise version to install (see https://github.com/jdx/mise/releases)
MISE_VERSION?=v2026.1.5 ## Mise version to install

# Path to mise binary
MISE_BIN=$(PATH_RUN)/bin/mise-$(MISE_VERSION) ## Mise executable path

# --
# ## CLI Check

# Extend CLI check to search via mise
USE_CLI_CHECK+=|| which $(MISE_BIN) && $(MISE_VERSION) -x which $1 2> /dev/null ## CLI check via mise

# EOF
