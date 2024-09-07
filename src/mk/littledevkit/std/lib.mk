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
# FILE FUNCTIONS
#
# -----------------------------------------------------------------------------

# --
#  `rwildcard PATH PATTERN`, eg `$(call rwildcard,src/py,*.py)` will match all
#  files in `PATH` (recursively) and also matching patterns.
rwildcard=$(wildcard $(subst SUF,$(strip $(if $2,$2,.)),$(strip $(subst PRE,$(if $1,$1,.)),PRE/SUF PRE/*/SUF PRE/*/*/SUF PRE/*/*/*/SUF PRE/*/*/*/*/SUF PRE/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/*/*/SUF)))

# -----------------------------------------------------------------------------
#
# LOGGING FUNCTIONS
#
# -----------------------------------------------------------------------------
fmt-tip=$(SPACE)👉   $(COLOR_INFO)$1$(RESET)



# EOF
