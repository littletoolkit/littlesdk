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
MODULES_PATH:=$(patsubst %.mk,%,$(lastword $(MAKEFILE_LIST)))
MODULES?=$(MODULES_AVAILABLE)
KIT_TITLE?=
KIT_HLO?=🧰 $(BOLD)LittleBuild$(if $(KIT_TITLE), ― $(KIT_TITLE))$(RESET)
KIT_LOGGING?=quiet

include $(MODULES_PATH)/std/lib.mk
$(info ┉┅━┅┉ ━━━ $(KIT_HLO)$(RESET))
include $(MODULES_PATH)/std/config.mk
include $(MODULES_PATH)/std/rules.mk

def-kit-include=$(EOL)$(if $(filter quiet,$(KIT_LOGGING)),,$(info $(call fmt_action,Load $(call fmt_module,$1))))$(EOL)include $1
# FIXME: That won't work if we have modules found elsewhere than MODULES_PATH
define def-kit-module-load
$(if $(wildcard src/mk/$1),$(call def-kit-include,src/mk/$1))
$(foreach K,$(filter-out std,$(MODULES)),$(if $(wildcard $(MODULES_PATH)/$K/$1),$(call def-kit-include,$(MODULES_PATH)/$K/$1)))
endef
$(eval $(call def-kit-module-load,config.mk))
$(eval $(call def-kit-module-load,lib.mk))
$(eval $(call def-kit-module-load,rules.mk))

# EOF
