MISE_DEBUG?=0
MISE_QUIET?=0

# SEE releases there https://github.com/jdx/mise/releases

# --
# Version for `mise`
MISE_VERSION?=v2026.1.5

MISE_BIN=$(PATH_BIN)/bin/mise-$(MISE_VERSION)

USE_CLI_CHECK+=|| which $(MISE_BIN) && $(MISE_VERSION) -x which $1 2> /dev/null
#
