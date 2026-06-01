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
REGULAR               :=$(call termcap,setaf 7)
BOLD                  :=$(call termcap,bold)
HI                    :=$(call termcap,smso)
NOHI                  :=$(call termcap,rmso)
UNDERLINE             :=$(call termcap,smul)
NOLINE                :=$(call termcap,rmul)
REV                   :=$(call termcap,rev)
DIM                   :=$(call termcap,dim)

BLUE_DK               :=$(call termcap,setaf 27)
BLUE                  :=$(call termcap,setaf 33)
BLUE_LT               :=$(call termcap,setaf 117)
YELLOW                :=$(call termcap,setaf 226)
ORANGE                :=$(call termcap,setaf 208)
GREEN                 :=$(call termcap,setaf 118)
GOLD                  :=$(call termcap,setaf 214)
GOLD_DK               :=$(call termcap,setaf 208)
CYAN                  :=$(call termcap,setaf 51)
RED                   :=$(call termcap,setaf 196)
PURPLE_DK             :=$(call termcap,setaf 55)
PURPLE                :=$(call termcap,setaf 92)
PURPLE_LT             :=$(call termcap,setaf 163)
GRAY                  :=$(call termcap,setaf 153)
GRAYLT                :=$(call termcap,setaf 231)

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
			echo "$(call fmt_action,∷ $(call fmt_path,$@))"
		;;
		*run*|*clean*)
			echo "$(call fmt_action,→ $(call fmt_rule,$@)) …"
			;;
		*)
			echo "$(call fmt_action,― $(call fmt_rule,$@)) …"
		;;
	esac
	$(call use_env)
endef

# --
# A generic function to be used when writing a rule. This will create the
# parent directories for build rules, and log messages for other rules.
define rule_post_cmd
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

shell_env=env -i $(call shell_env_vars) $(call shell_export_vars) $1
shell_ensure=if ! $1; then echo "$(call fmt_error,Command failed $(subst ","'"'",$1))"; exit 1; fi
shell_fail=echo "$(call fmt_error,$1)"; if [ -e "$@" ]; then unlink "$@"; fi; exit 1
shell_succeed=mkdir -p "$(dir $@)";echo "$1" > "$@"
shell_build=if ! $1; then $(call shell_fail,$2); else $(call shell_succeed,$3); fi
shell_download=mkdir -p "$(dir $@)"; if ! curl -L -o "$@" "$1"; then $(call shell_fail,Could not download $1); else echo "$(call fmt_output,Downloaded $@ from $1)"; fi



# List SHELL_ENV variables as NAME=VALUE
shell_env_vars=$(foreach V,$(SHELL_ENV),$(if $(filter undefined,$(origin ENV_$V)),$(if $(filter undefined,$(origin $V)),,$V="$(strip $($V))"),$V="$(strip $(ENV_$V))"))
# List SHELL_EXPORT variables as NAME=VALUE
shell_export_vars=$(foreach V,$(SHELL_EXPORTS),$(if $(filter undefined,$(origin $V)),,$V="$(strip $($V))"))
# Generate export statements to be evaluated in the makefile
make_export_vars=$(subst :,$(SPACE),$(subst $(SPACE),$(EOL),$(foreach V,$(SHELL_EXPORTS),$(if $(filter undefined,$(origin $V)),,export:$V))))


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

# =============================================================================
# SHELL FUNCTIONS
# =============================================================================

cmd_sha256=echo -n '$(subst ',_,$1)' | openssl sha256 | cut -d' ' -f2
hash_sha256=$(shell echo -n '$(subst ',_,$1)' | openssl sha256 | cut -d' ' -f2)

# -----------------------------------------------------------------------------
#
# LIBRARY FUNCTIONS
#
# -----------------------------------------------------------------------------

uniq=$(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1)))
filter_find=$(foreach V,$2,$(if $(findstring $1,$V),$V,,))
filter_find_not=$(foreach V,$2,$(if $(findstring $1,$V),,$V))
#
# get_tuple(TUPLE) where TUPLE is colon-separated values
get_tuple=$(subst :,$(SPACE),$1)
get_nth=$(word $1,$(call get_tuple,$2))
get_default=$(firstword $(strip $1 $2 $3 $4 $5 $6 $7))
get_ensure=$(if $1,$1,$(error $(call fmt_error,Value for '$2' is required)))
get_var=$(if $(filter $1,$(.VARIABLES)),$($1),)
is_true=$(if $(filter yes,$1)$(filter true,$1),yes)

has_vars=$(if $(foreach T,$1 $2 $3 $4 $5 $6 $7,$$T),1)
use_vars=$(PATH_RUN_DEPS)/$(shell echo -n "$(foreach V,$1 $2 $3 $4 $5 $6 $7,$($V))" | openssl sha256 | cut -d' ' -f2).data
use_data=$(PATH_RUN_DEPS)/$(shell echo -n "$1 $2 $3 $4 $5 $6 $7" | openssl sha256 | cut -d' ' -f2).data
use_task=$(foreach T,$1 $2 $3 $4 $5 $6 $7,$(PATH_RUN_TASK)/$T.task)
use_tool=$(foreach M,$1 $2 $3 $4 $5 $6 $7,$(PATH_RUN_TASK)/tool-$M.task)
use_package=$(if $2,$(PATH_RUN_TASK)/install-package-$1@$2.task,$(PATH_RUN_TASK)/install-package-$1.task)

# -----------------------------------------------------------------------------
#
# FORMATTING FUNCTIONS
#
# -----------------------------------------------------------------------------
get_prefix=$(if $(filter [%,$1),$(firstword $(subst ],$(SPACE),$1))],$(FMT_PREFIX))
strip_prefix=$(strip $(if $(filter [%,$1),$(subst $(call get_prefix,$1),,$1),$1))
fmt_prefix=$(BOLD)$(if $1,$(call get_prefix,$1),$(FMT_PREFIX))$(RESET)
fmt_error=$(COLOR_ERROR)$(call get_prefix,$1)$(RESET) $(call strip_prefix,$1)$(RESET)
fmt_warn =$(COLOR_WARNING)$(call get_prefix,$1)$(RESET) $(call strip_prefix,$1)$(RESET)
fmt_tip   =$(call fmt_prefix,$1)$(SPACE) 👉 $(call strip_prefix,$1)$(RESET)
fmt_message=$(call fmt_prefix,$1)$(SPACE) = $(call strip_prefix,$1)$(RESET)
fmt_action=$(call fmt_prefix,$1) → $(call strip_prefix,$1)$(RESET)
fmt_result=$(call fmt_prefix,$1) ← $(call strip_prefix,$1)$(RESET)
fmt_path=$(GOLD)$(dir $1)$(BOLD)$(notdir $1)$(RESET)
fmt_output=$(GREEN)$(BOLD)$1$(RESET)
fmt_module=🞐  $(lastword $(strip $(subst /,$(SPACE),$(dir $1))))/$(BOLD)$(notdir $1)$(RESET)
fmt_rule=$(if $2,$2,🞖)  $(BOLD)$1$(RESET)
fmt_shortcode=$(call get_default,$(call get_item_value,$1,$(SHORTCODES)),$1)
fmt_makecmd=$(strip $(SDK_MAKE) $1 $(filter %=%,$(MAKEFLAGS)))
fmt_icon=$(if $(filter prod%,$1),🔴,$(if $(filter uat%,$1),🟠,$(if $(filter stag%,$1),🟡,🟢)))
fmt_count=$(DIM)[$1]$(RESET)


# EOF
