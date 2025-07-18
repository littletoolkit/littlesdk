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
LB_PATH:=$(dir $(lastword $(MAKEFILE_LIST)))../..
MODULES_PATH:=$(patsubst %.mk,%,$(lastword $(MAKEFILE_LIST)))
MODULES?=$(MODULES_AVAILABLE)
LB_TITLE?=
LB_HLO?=🧰 $(BOLD)LittleBuild$(if $(LB_TITLE), ― $(LB_TITLE))$(RESET)
LB_LOGGING?=


# We load the standard library first
include $(MODULES_PATH)/std/lib.mk
include $(MODULES_PATH)/std/config.mk
$(info ┉┅━┅┉ ━━━ $(LB_HLO)$(RESET))

def-include=$(EOL)$(if $(filter quiet,$(LB_LOGGING)),,$(info $(call fmt_action,Load $(call fmt_module,$1))))$(EOL)include $1
# FIXME: That won't work if we have modules found elsewhere than MODULES_PATH
define def-module-load
$(if $(wildcard src/mk/$1),$(call def-include,src/mk/$1))
$(foreach K,$(filter-out std,$(MODULES)),$(if $(wildcard $(MODULES_PATH)/$K/$1),$(call def-include,$(MODULES_PATH)/$K/$1)))
endef
$(eval $(call def-module-load,config.mk))
# Standard rules are loaded first
include $(MODULES_PATH)/std/rules.mk
$(eval $(call def-module-load,rules.mk))

#
# EOF
