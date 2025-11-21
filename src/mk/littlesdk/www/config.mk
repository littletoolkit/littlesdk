PORT?=8000

WWW_PATH=$(PATH_DIST)/www

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


WWW_DIST_ALL=
# DIST_WWW_ALL+=\
# 	$(SOURCES_HTML:$(PATH_SRC)/html/%.html=$(PATH_DIST)/www/%.html)\
# 	$(SOURCES_XML:$(PATH_SRC)/xml/%.xml=$(PATH_DIST)/www/%.html)\
# 	$(SOURCES_CSS:$(PATH_SRC)/css/%.css=$(PATH_DIST)/www/lib/css/%.css)\
# 	$(SOURCES_CSS_JS:$(PATH_SRC)/css/%.js=$(PATH_DIST)/www/lib/css/%.css)\
# 	$(SOURCES_JS:$(PATH_SRC)/js/%.js=$(PATH_DIST)/www/lib/js/%.js)\
# 	$(SOURCES_JSON:$(PATH_SRC)/json/%.json=$(PATH_DIST)/www/lib/json/%.json)
#
DIST_ALL+=$(WWW_DIST_ALL)
RUN_ALL+=$(WWW_RUN_ALL)
# EOF

