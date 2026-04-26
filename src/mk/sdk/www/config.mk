PORT?=8000

PATH_DIST_WWW=$(PATH_DIST)/www

# --
# HTML Tidy command via mise
HTMLTIDY?=$(CMD) tidy --custom-tags blocklevel

# =============================================================================
# BUILD
# =============================================================================

# HTML: Tidied HTML files from src/html/* to build/html/*
BUILD_HTML=\
	$(SOURCES_HTML:$(PATH_SRC)/html/%.html=$(PATH_BUILD)/html/%.html)

# XML: Transformed to HTML via xsltproc
BUILD_XML=\
	$(SOURCES_XML:$(PATH_SRC)/xml/%.xml=$(PATH_BUILD)/xml/%.html)

# CSS from JS: Compiled CSS from src/css/*.js to build/css/*.css
BUILD_CSS_JS=\
	$(SOURCES_CSS_JS:$(PATH_SRC)/css/%.js=$(PATH_BUILD)/css/%.css)

WWW_BUILD_ALL=\
	$(BUILD_HTML)\
	$(BUILD_XML)\
	$(BUILD_CSS_JS)

BUILD_ALL+=$(WWW_BUILD_ALL)

# =============================================================================
# RUN
# =============================================================================

WWW_RUN_ALL+=\
	$(SOURCES_HTML:$(PATH_SRC)/html/%.html=$(PATH_RUN)/%.html)\
	$(SOURCES_XML:$(PATH_SRC)/xml/%.xml=$(PATH_RUN)/%.xml)\
	$(SOURCES_XSLT:$(PATH_SRC)/xslt/%.xslt=$(PATH_RUN)/lib/xslt/%.xslt)\
	$(SOURCES_CSS:$(PATH_SRC)/css/%.css=$(PATH_RUN)/lib/css/%.css)\
	$(SOURCES_CSS_JS:$(PATH_SRC)/css/%.js=$(PATH_RUN)/lib/css/%.js)\
	$(SOURCES_CSS_JS:$(PATH_SRC)/css/%.js=$(PATH_RUN)/lib/css/%.css)\
	$(SOURCES_JS:$(PATH_SRC)/js/%.js=$(PATH_RUN)/lib/js/%.js)\
	$(SOURCES_TS:$(PATH_SRC)/ts/%.ts=$(PATH_RUN)/lib/js/%.js)\
	$(SOURCES_JSON:$(PATH_SRC)/json/%.json=$(PATH_RUN)/lib/json/%.json)

RUN_ALL+=$(WWW_RUN_ALL)

# =============================================================================
# DIST
# =============================================================================

# HTML: from build/html (tidied) to dist/www
WWW_DIST_HTML=\
	$(SOURCES_HTML:$(PATH_SRC)/html/%.html=$(PATH_DIST_WWW)/%.html)

# XML: from build/xml (transformed) to dist/www
WWW_DIST_XML=\
	$(SOURCES_XML:$(PATH_SRC)/xml/%.xml=$(PATH_DIST_WWW)/%.html)

# JS/TS: reuse JS module build outputs (BUILD_JS -> dist/www/lib/js)
# Only included if WWW_DIST_MODE contains "js:module"
WWW_DIST_JS=\
	$(if $(findstring js:module,$(WWW_DIST_MODE)),$(patsubst $(JS_BUILD_PATH)/%,$(PATH_DIST_WWW)/lib/js/%,$(BUILD_JS)))

# CSS: copy from src/css to dist/www/lib/css
WWW_DIST_CSS=\
	$(SOURCES_CSS:$(PATH_SRC)/css/%.css=$(PATH_DIST_WWW)/lib/css/%.css)

# CSS from JS: from build/css (compiled) to dist/www/lib/css
WWW_DIST_CSS_JS=\
	$(SOURCES_CSS_JS:$(PATH_SRC)/css/%.js=$(PATH_DIST_WWW)/lib/css/%.css)

# JSON: copy from src/json to dist/www/lib/json
WWW_DIST_JSON=\
	$(SOURCES_JSON:$(PATH_SRC)/json/%.json=$(PATH_DIST_WWW)/lib/json/%.json)

# Data: copy from src/data to dist/www/data (preserve structure)
WWW_DIST_DATA=\
	$(SOURCES_DATA:$(PATH_SRC)/data/%=$(PATH_DIST_WWW)/data/%)

# Static: copy from src/static to dist/www/static (preserve structure)
WWW_DIST_STATIC=\
	$(SOURCES_STATIC:$(PATH_SRC)/static/%=$(PATH_DIST_WWW)/static/%)

# =============================================================================
# BUNDLE (Standalone production build assets)
# =============================================================================

# UICSS compiled to static CSS (for production)
WWW_BUNDLE_UICSS?=$(PATH_DIST_WWW)/ui.css

# Project CSS copied to dist
WWW_BUNDLE_CSS?=$(PATH_DIST_WWW)/style.css

# Production index.html (only when JS_BUNDLE_ENTRY is set)
WWW_BUNDLE_INDEX?=$(if $(JS_BUNDLE_ENTRY),$(PATH_DIST_WWW)/index.html)

# Debug index.html (only when JS_BUNDLE_ENTRY is set)
WWW_BUNDLE_DEBUG_INDEX?=$(if $(JS_BUNDLE_ENTRY),$(PATH_DIST_WWW)/index.debug.html)

# FIXME: This should be moved to js or www
# --
# Distribution mode controls what gets included in dist output.
# Supports multiple space-separated modes:
#   js:module - Include individual JS modules in dist/lib/js/*
#   js:bundle - Include bundled JS assets in dist/www/
WWW_DIST_MODE?=js:module


WWW_DIST_BUNDLE=\
	$(WWW_BUNDLE_UICSS)\
	$(WWW_BUNDLE_CSS)\
	$(WWW_BUNDLE_INDEX)\
	$(WWW_BUNDLE_DEBUG_INDEX)


WWW_DIST_ALL=\
	$(WWW_DIST_HTML)\
	$(WWW_DIST_XML)\
	$(WWW_DIST_JS)\
	$(WWW_DIST_CSS)\
	$(WWW_DIST_CSS_JS)\
	$(WWW_DIST_JSON)\
	$(WWW_DIST_DATA)\
	$(WWW_DIST_STATIC)\
	$(if $(findstring js:bundle,$(WWW_DIST_MODE)),$(WWW_DIST_BUNDLE))

DIST_ALL+=$(WWW_DIST_ALL)

# EOF
