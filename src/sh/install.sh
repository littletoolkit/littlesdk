#!/usr/bin/env bash
env P="${PATH_DEPS:-deps}" mkdir -p "$P" && git clone git@github.com:sebastien/littledevkit.git "$P" && echo "Setup LittleDevKit: make -f $P/setup.mk"
# EOF
