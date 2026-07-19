# --
# Squint ClojureScript support. This module relies on the JS module for the
# runtime command and builds ESM modules alongside JavaScript build outputs.
CLJS_RUN?=$(JS_RUN) squint
CLJS_CONFIG?=squint.edn
CLJS_BUILD_PATH?=$(JS_BUILD_PATH)
CLJS_EXTENSION?=.mjs
CLJS_SOURCES?=$(SOURCES_CLS)
CLJS_BUILD_ALL?=$(patsubst $(PATH_SRC)/cljs/%.cljs,$(CLJS_BUILD_PATH)/%$(CLJS_EXTENSION),$(CLJS_SOURCES))
CLJS_BUILD_DEPS=$(CLJS_SOURCES) $(wildcard $(CLJS_CONFIG))

CLJS_BUILD_ALL_PHASE=$(CLJS_BUILD_ALL)
CLJS_CHECK_ALL=$(if $(strip $(CLJS_SOURCES)),cljs-check)

BUILD_ALL+=$(CLJS_BUILD_ALL_PHASE)
CHECK_ALL+=$(CLJS_CHECK_ALL)
# EOF
