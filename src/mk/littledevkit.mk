# --
# We define the basic make configuration flags and shell.
SHELL:=bash
.SHELLFLAGS:=-euo pipefail -c
MAKEFLAGS+=--warn-undefined-variables
MAKEFLAGS+=--no-builtin-rules
.ONESHELL:
.FORCE:

# --
# We load the standard library, at which point we'll
# be able to load the modules
KIT_PATH:=$(dir $(lastword $(MAKEFILE_LIST)))../..
KIT_MODULES_PATH:=$(patsubst %.mk,%,$(lastword $(MAKEFILE_LIST)))
KIT_MODULES?=$(KIT_MODULES_AVAILABLE)
KIT_TITLE?=
KIT_HLO?=🧰 $(BOLD)LittleDevKit$(if $(KIT_TITLE), ― $(KIT_TITLE))$(RESET)
KIT_LOGGING?=

include $(KIT_MODULES_PATH)/std/lib.mk
$(info ┉┅━┅┉ ━━━ $(KIT_HLO)$(RESET))
include $(KIT_MODULES_PATH)/std/config.mk
include $(KIT_MODULES_PATH)/std/rules.mk

def-kit-include=$(EOL)$(if $(filter quiet,$(KIT_LOGGING)),,$(info $(call fmt-action,Load $(call fmt-module,$1))))$(EOL)include $1
# FIXME: That won't work if we have modules found elsewhere than KIT_MODULES_PATH
define def-kit-module-load
$(if $(wildcard src/mk/$1),$(call def-kit-include,src/mk/$1))
$(foreach K,$(filter-out std,$(KIT_MODULES)),$(if $(wildcard $(KIT_MODULES_PATH)/$K/$1),$(call def-kit-include,$(KIT_MODULES_PATH)/$K/$1)))
endef
$(eval $(call def-kit-module-load,config.mk))
$(eval $(call def-kit-module-load,lib.mk))
$(eval $(call def-kit-module-load,rules.mk))

# EOF
