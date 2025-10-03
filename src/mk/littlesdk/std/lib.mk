# Core variables
NULL:=
SPACE:=$(NULL) $(NULL)
COMMA:=,
define EOL
$(if 1,
,)
endef

# -----------------------------------------------------------------------------
#
# ARGS
#
# -----------------------------------------------------------------------------

# We define them so that we don't get warnings for undefined variables
1?=
2?=
3?=
4?=
5?=
6?=
7?=

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

# --
# A generic function to be used when writing a rule. This will create the
# parent directories for build rules, and log messages for other rules.
define rule_pre_cmd
	case "$@" in
		*/*)
			if [ -n "$(dir $@)" ] && [ ! -e "$(dir $@)" ]; then
				mkdir -p "$(dir $@)"
			fi
			echo "$(call fmt_action,Make $(call fmt_path,$@)) 🖫"
		;;
		*run*|*clean*)
			echo "$(call fmt_action,Does $(call fmt_rule,$@)) …"
			;;
		*)
			echo "$(call fmt_action,Done $(call fmt_rule,$@)) ✔ "
		;;
	esac
	$(call use_env)
endef

# --
# A generic function to be used when writing a rule. This will create the
# parent directories for build rules, and log messages for other rules.
define rule_post_cmd
	echo "       ⤷  $(if $1,🗅 × $(words $1) : $(BOLD)$(strip $1),$@)$(RESET)"
endef

# -----------------------------------------------------------------------------
#
# SHELL HELPERS
#
# -----------------------------------------------------------------------------

# --
# `$(call sh_check_defined,STRING)` will fail with an error if `STRING`
# is empty.
define sh_check_defined
if [ -z "$($1)" ]; then
	echo "$(call fmt_error,Variable is undefined: $1)"
	exit 1
fi
endef

# --
# `$(call sh_check_exists,PATH)` will fail if `PATH` is undefined or
# does not exists.
define sh_check_exists
if [ -z "$1" ]; then
	echo "$(call fmt_error,Variable is undefined)"
	exit 1
elif [ ! -e "$1" ]; then
	echo "$(call fmt_error,Path does not exist: $(call fmt_path,$1))"
	exit 1
fi
endef

# --
# `$(call sh_install_tool,PATH)` will install the tool at `PATH` under `run/bin`.
define sh_install_tool
if [ ! -e "$1" ]; then
	echo "$(call fmt_error,Cannot install tool as it is missing: $(call fmt_path,$1))"
	exit 1
fi
if [ ! -d "run/bin" ]; then
	mkdir -p "run/bin"
fi
echo "$(call fmt_action,Installing tool $(BOLD)$(notdir $1))"
ln -sfr "$1" "run/bin/$(notdir $1)"
endef

# -----------------------------------------------------------------------------
#
# DEPENDENCIES
#
# -----------------------------------------------------------------------------

use_cmd=$1
use_env=$(foreach E,$(if $1,$1 $2 $3 $4 $5 $6,PATH PYTHONPATH),export $E=$(ENV_$E);)
use_cli=$(foreach M,$1 $2 $3 $4 $5 $6 $7,build/cli-$M.task)

# -----------------------------------------------------------------------------
#
# FILE FUNCTIONS
#
# -----------------------------------------------------------------------------

# --
#  `file_find PATH PATTERN`, eg `$(call file_find,src/py,*.py)` will match all
#  files in `PATH` (recursively) and also matching patterns.
file_find=$(wildcard $(subst SUF,$(strip $(if $2,$2,.)),$(strip $(subst PRE,$(if $1,$1,.),PRE/SUF PRE/*/SUF PRE/*/*/SUF PRE/*/*/*/SUF PRE/*/*/*/*/SUF PRE/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/*/*/SUF))))

# -----------------------------------------------------------------------------
#
# SHELL FUNCTIONS
#
# -----------------------------------------------------------------------------

# Function: shell_create_if 1:COMMAND 2:FAILMESSAGE? 3:SUCCESS? 4:CLEANUP?
# - COMMAND: The command to run
# - FAILMESSAGE: `Command failed: …`
# - SUCCESS: `touch "$@"`
# - CLEANUP: `test -e "$@" && unlink "$@"`
define shell_create_if
	if $1; then
		$(if $3,$3,touch "$@")
	else
		echo "$(call fmt_error,$(if $2,$2,Command failed: $(subst ",',$1)))"
		$(if $4,$4,test -e "$@" && unlink "$@")
		exit 1
	fi
endef

define shell_try
	if ! $1; then
		echo "$(call fmt_error,$(if $2,$2,Command failed: $(subst ",',$1)))"
		$(if $4,$4,test -e "$@" && unlink "$@")
		exit 1
	fi
endef

# -----------------------------------------------------------------------------
#
# FORMATTING FUNCTIONS
#
# -----------------------------------------------------------------------------

fmt_prefix=$(BOLD)$(FMT_PREFIX)$(RESET)
fmt_error=$(COLOR_ERROR)$(FMT_PREFIX)$(RESET)
fmt_tip   =$(call fmt_prefix)$(SPACE)👉   $1$(RESET)
fmt_action=$(call fmt_prefix)  →  $1$(RESET)
fmt_result=$(call fmt_prefix)  ←  $1$(RESET)
fmt_path=🗅  $(dir $1)$(BOLD)$(notdir $1)$(RESET)
fmt_module=🖸  $(lastword $(strip $(subst /,$(SPACE),$(dir $1))))/$(BOLD)$(notdir $1)$(RESET)
fmt_rule=$(if $2,$2,➳)  $(BOLD)$1$(RESET)

# EOF
