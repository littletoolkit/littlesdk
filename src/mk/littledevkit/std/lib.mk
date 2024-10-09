# Core variables
NULL:=
SPACE:=$(NULL) $(NULL)
define EOL
$(if 1,
,)
endef

# -----------------------------------------------------------------------------
#
# ARGS
#
# -----------------------------------------------------------------------------
1?=
2?=
3?=

# -----------------------------------------------------------------------------
#
# COLORS
#
# -----------------------------------------------------------------------------

# --
# ## Colors

NO_COLOR?=
# --
# Uses `tput` to retrieve the term code, respecting https://no-color.org/
# SEE https://www.gnu.org/software/termutils/manual/termutils-2.0/html_chapter/tput_1.html#SEC8
ifneq (,$(shell which tput 2> /dev/null))
termcap=$(if $(NO_COLOR),,$(shell TERM="$(TERM)" echo $$(tput $1)))
else
termcap=
endif
TERM?=
TERM?=xterm-color
GRAY                  :=$(call termcap,setaf 153)
# GRAYLT              :=$(call termcap,setaf 231)
RESET                 :=$(call termcap,sgr0)
BOLD                  :=$(call termcap,bold)
HI                    :=$(call termcap,smso)
NOHI                  :=$(call termcap,rmso)
UNDERLINE             :=$(call termcap,smul)
NOLINE                :=$(call termcap,rmul)
REV                   :=$(call termcap,rev)
DIM                   :=$(call termcap,dim)
COLOR_DETAIL          :=$(call termcap,setaf 38)
COLOR_DEBUG           :=$(call termcap,setaf 31)
COLOR_INFO            :=$(call termcap,setaf 75)
COLOR_CHECKPOINT      :=$(call termcap,setaf 81)
COLOR_WARNING         :=$(call termcap,setaf 202)
COLOR_ERROR           :=$(call termcap,setaf 160)
COLOR_EXCEPTION       :=$(call termcap,setaf 124)
COLOR_ALERT           :=$(call termcap,setaf 89)
COLOR_CRITICAL        :=$(call termcap,setaf 163)

# -----------------------------------------------------------------------------
#
# RULE FUNCTION
#
# -----------------------------------------------------------------------------

define rule-pre-cmd
	case "$@" in
		*/*)
			if [ -n "$(dir $@)" ] && [ ! -e "$(dir $@)" ]; then
				mkdir -p "$(dir $@)"
			fi
			echo "$(call fmt-action,Make $(call fmt-path,$@)) 🖫"
		;;
		*run*|*clean*)
			echo "$(call fmt-action,Does $(call fmt-rule,$@)) …"
			;;
		*)
			echo "$(call fmt-action,Done $(call fmt-rule,$@)) ✔ "
		;;
	esac
	$(call use-env)
endef
define rule-post-cmd
	echo "       ⤷  $(if $1,🗅 × $(words $1) : $(BOLD)$(strip $1),$@)$(RESET)"
endef

# -----------------------------------------------------------------------------
#
# SHELL HELPERS
#
# -----------------------------------------------------------------------------

define sh-check-defined
if [ -z "$($1)" ]; then
	echo "$(call fmt-error,Variable is undefined: $1)" exit 1
fi
endef

define sh-check-exists
if [ -z "$1" ]; then
	echo "$(call fmt-error,Variable is undefined)"
	exit 1
elif [ ! -e "$1" ]; then
	echo "$(call fmt-error,Path does not exist: $(call fmt-path,$1))"
	exit 1
fi
endef

define install-tool
if [ ! -e "$1" ]; then
	echo "$(call fmt-error,Cannot install tool as it is missing: $(call fmt-path,$1))"
	exit 1
fi
if [ ! -d "run/bin" ]; then
	mkdir -p "run/bin"
fi
echo "$(call fmt-action,Installing tool $(BOLD)$(notdir $1))"
ln -sfr "$1" "run/bin/$(notdir $1)"
endef

# -----------------------------------------------------------------------------
#
# DEPENDENCIES
#
# -----------------------------------------------------------------------------

use-cmd=$1
use-env=$(foreach E,$(if $1,$1 $2 $3 $4 $5 $6,PATH PYTHONPATH),export $E=$(ENV_$E);)

# -----------------------------------------------------------------------------
#
# FILE FUNCTIONS
#
# -----------------------------------------------------------------------------

# --
#  `file-find PATH PATTERN`, eg `$(call file-find,src/py,*.py)` will match all
#  files in `PATH` (recursively) and also matching patterns.
file-find=$(wildcard $(subst SUF,$(strip $(if $2,$2,.)),$(strip $(subst PRE,$(if $1,$1,.),PRE/SUF PRE/*/SUF PRE/*/*/SUF PRE/*/*/*/SUF PRE/*/*/*/*/SUF PRE/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/*/*/SUF))))
# -----------------------------------------------------------------------------
#
# FORMATTING FUNCTIONS
#
# -----------------------------------------------------------------------------

fmt-prefix=$(BOLD)$(FMT_PREFIX)$(RESET)
fmt-error=$(COLOR_ERROR)$(FMT_PREFIX)$(RESET)
fmt-tip   =$(call fmt-prefix)$(SPACE)👉   $1$(RESET)
fmt-action=$(call fmt-prefix)  →  $1$(RESET)
fmt-path=🗅  $(dir $1)$(BOLD)$(notdir $1)$(RESET)
fmt-module=🖸  $(lastword $(strip $(subst /,$(SPACE),$(dir $1))))/$(BOLD)$(notdir $1)$(RESET)
fmt-rule=$(if $2,$2,➳)  $(BOLD)$1$(RESET)

# EOF
