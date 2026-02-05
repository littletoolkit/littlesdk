# -----------------------------------------------------------------------------
#
# LITTLESDK CORE MODULE LOADER
#
# -----------------------------------------------------------------------------

# Main entry point for LittleSDK module system. Loads configuration and rules
# from registered modules, handling module dependencies and initialization order.

# -----------------------------------------------------------------------------
#
# SHELL CONFIGURATION
#
# -----------------------------------------------------------------------------

SHELL:=bash
.SHELLFLAGS:=-euo pipefail -c
MAKEFLAGS+=--warn-undefined-variables
MAKEFLAGS+=--no-builtin-rules
.ONESHELL:
.FORCE:

# -----------------------------------------------------------------------------
#
# PATHS AND MODULES
#
# -----------------------------------------------------------------------------

# --
# ## SDK Paths

# Internal path calculation (relative from SDK root)
_SDK_PATH:=$(subst $(realpath .)/,,$(realpath $(dir $(lastword $(MAKEFILE_LIST)))../..))

# Path to SDK root directory (defaults to current directory)
SDK_PATH:=$(if $(_SDK_PATH),$(_SDK_PATH),./)

# Path to module definitions (directory containing this file)
MODULES_PATH:=src/mk/littlesdk

# --
# ## SDK Configuration

# Active modules to load (defaults to all available)
MODULES?=$(MODULES_AVAILABLE)

# Optional title displayed in SDK header
SDK_TITLE?=

# Formatted header string for display
SDK_HLO?=🧰 $(BOLD)LittleSDK$(if $(SDK_TITLE), ― $(SDK_TITLE))$(RESET)

# Logging level (all, quiet, or error)
SDK_LOGGING?=all

# Prefix for formatted log messages
FMT_PREFIX?=[kit]

# -----------------------------------------------------------------------------
#
# FUNCTIONS
#
# -----------------------------------------------------------------------------

# --
# ## Module Loading

def-include=$(EOL)$(if $(filter quiet,$(SDK_LOGGING)),,$(info $(call fmt_action,Load $(call fmt_module,$1))))$(EOL)include $1

# FIXME: That won't work if we have modules found elsewhere than MODULES_PATH
define def-module-load
$(if $(wildcard src/mk/$(subst .mk,.pre.mk,$1)),$(call def-include,src/mk/$(subst .mk,.pre.mk,$1)))
$(if $(filter config.mk,$1),$(if $(wildcard src/mk/$1),$(call def-include,src/mk/$1)))
# NOTE: We skip the std module here, as it's already loaded
$(foreach K,$(filter-out std,$(MODULES)),$(if $(wildcard $(MODULES_PATH)/$K/$1),$(call def-include,$(MODULES_PATH)/$K/$1)))
$(if $(filter rules.mk,$1),$(if $(wildcard src/mk/$1),$(call def-include,src/mk/$1)))
$(if $(wildcard src/mk/$(subst .mk,.post.mk,$1)),$(call def-include,src/mk/$(subst .mk,.post.mk,$1)))
endef

# -----------------------------------------------------------------------------
#
# INITIALIZATION
#
# -----------------------------------------------------------------------------

# Load standard library for utility functions
include $(MODULES_PATH)/std/lib.mk

# Display SDK header on load
$(info ┉┅━┅┉ ━━━ $(SDK_HLO)$(RESET))

# Load configuration from all modules in order:
# 1. Standard library config
# 2. Module configs (in registration order)
$(eval $(call def-include,$(MODULES_PATH)/std/config.mk))
$(eval $(call def-module-load,config.mk))

# Load rules from all modules in order:
# 1. Standard library rules
# 2. Module rules (in registration order)
$(eval $(call def-include,$(MODULES_PATH)/std/rules.mk))
$(eval $(call def-module-load,rules.mk))

# EOF
