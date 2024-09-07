# Core variables
NULL:=
SPACE:=$(NULL) $(NULL)
define EOL
$(if 1,
,)
endef

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
ifneq (,$(shell which tput 2> /dev/null))
term-style=$(if $(NO_COLOR),,$(shell TERM="$(TERM)" echo $$(tput $1)))
else
term-style=
endif
TERM?=
TERM?=xterm-color
GRAY                  :=$(call term-style,setaf 153)
# GRAYLT              :=$(call term-style,setaf 231)
RESET                 :=$(call term-style,sgr0)
BOLD                  :=$(call term-style,bold)
HI                    :=$(call term-style,smso)
NOHI                  :=$(call term-style,rmso)
UNDERLINE             :=$(call term-style,smul)
NOLINE                :=$(call term-style,rmul)
REV                   :=$(call term-style,rev)
DIM                   :=$(call term-style,dim)
COLOR_DETAIL          :=$(call term-style,setaf 38)
COLOR_DEBUG           :=$(call term-style,setaf 31)
COLOR_INFO            :=$(call term-style,setaf 75)
COLOR_CHECKPOINT      :=$(call term-style,setaf 81)
COLOR_WARNING         :=$(call term-style,setaf 202)
COLOR_ERROR           :=$(call term-style,setaf 160)
COLOR_EXCEPTION       :=$(call term-style,setaf 124)
COLOR_ALERT           :=$(call term-style,setaf 89)
COLOR_CRITICAL        :=$(call term-style,setaf 163)

# -----------------------------------------------------------------------------
#
# FUNCTIONS
#
# -----------------------------------------------------------------------------

# --
#  `rwildcard PATH PATTERN`, eg `$(call rwildcard,src/py,*.py)` will match all
#  files in `PATH` (recursively) and also matching patterns.
rwildcard=$(wildcard $(subst SUF,$(strip $(if $2,$2,.)),$(strip $(subst PRE,$(if $1,$1,.)),PRE/SUF PRE/*/SUF PRE/*/*/SUF PRE/*/*/*/SUF PRE/*/*/*/*/SUF PRE/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/*/*/SUF)))

# EOF
