# We respect https://no-color.org/
NO_COLOR?=
NO_INTERACTIVE?=
TERM?=
YELLOW        ?=
ORANGE        ?=
GREEN         ?=
GOLD          ?=
GOLD_DK       ?=
BLUE_DK       ?=
BLUE          ?=
BLUE_LT       ?=
CYAN          ?=
RED           ?=
PURPLE_DK     ?=
PURPLE        ?=
PURPLE_LT     ?=
GRAY          ?=
GRAYLT        ?=
REGULAR       ?=
RESET         ?=
BOLD          ?=
UNDERLINE     ?=
REV           ?=
DIM           ?=
ifneq (,$(shell which tput 2> /dev/null))
ifeq (,$(NO_COLOR))
TERM?=xterm-color
BLUE_DK       :=$(shell TERM="$(TERM)" echo $$(tput setaf 27))
BLUE          :=$(shell TERM="$(TERM)" echo $$(tput setaf 33))
BLUE_LT       :=$(shell TERM="$(TERM)" echo $$(tput setaf 117))
YELLOW        :=$(shell TERM="$(TERM)" echo $$(tput setaf 226))
ORANGE        :=$(shell TERM="$(TERM)" echo $$(tput setaf 208))
GREEN         :=$(shell TERM="$(TERM)" echo $$(tput setaf 118))
GOLD          :=$(shell TERM="$(TERM)" echo $$(tput setaf 214))
GOLD_DK       :=$(shell TERM="$(TERM)" echo $$(tput setaf 208))
CYAN          :=$(shell TERM="$(TERM)" echo $$(tput setaf 51))
RED           :=$(shell TERM="$(TERM)" echo $$(tput setaf 196))
PURPLE_DK     :=$(shell TERM="$(TERM)" echo $$(tput setaf 55))
PURPLE        :=$(shell TERM="$(TERM)" echo $$(tput setaf 92))
PURPLE_LT     :=$(shell TERM="$(TERM)" echo $$(tput setaf 163))
GRAY          :=$(shell TERM="$(TERM)" echo $$(tput setaf 153))
GRAYLT        :=$(shell TERM="$(TERM)" echo $$(tput setaf 231))
REGULAR       :=$(shell TERM="$(TERM)" echo $$(tput setaf 7))
RESET         :=$(shell TERM="$(TERM)" echo $$(tput sgr0))
BOLD          :=$(shell TERM="$(TERM)" echo $$(tput bold))
UNDERLINE     :=$(shell TERM="$(TERM)" echo $$(tput smul))
REV           :=$(shell TERM="$(TERM)" echo $$(tput rev))
DIM           :=$(shell TERM="$(TERM)" echo $$(tput dim))
endif
endif
