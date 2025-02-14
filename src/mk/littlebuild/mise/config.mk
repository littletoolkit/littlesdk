MISE_DEBUG?=0
MISE_QUIET?=0
# SEE releases there https://github.com/jdx/mise/releases
MISE_VERSION?=v2025.2.3
MISE_BIN=run/bin/mise-$(MISE_VERSION)
USE_CLI_CHECK+=|| which $(MISE_BIN) && $(MISE_VERSION) -x which $1 2> /dev/null
# EOF
