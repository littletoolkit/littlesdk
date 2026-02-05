#!/usr/bin/env bash
env P="${PATH_DEPS:-deps}" mkdir -p "$P" && git clone git@github.com:littletoolkit/littlesdk.git "$P" && echo "Setup LittleBuild: gmake -f $P/setup.mk"
# EOF
