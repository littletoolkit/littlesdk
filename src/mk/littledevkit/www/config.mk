PORT?=8000

RUN_WWW_ALL?=\
	$(SOURCES_HTML:src/html/%.html=run/%.html)\
	$(SOURCES_XML:src/xml/%.xml=run/%.xml)\
	$(SOURCES_XSLT:src/xslt/%.xslt=run/lib/xslt/%.xslt)\
	$(SOURCES_CSS:src/css/%.css=run/lib/css/%.css)\
	$(SOURCES_CSS_JS:src/css/%.js=run/lib/css/%.js)\
	$(SOURCES_CSS_JS:src/css/%.js=run/lib/css/%.css)\
	$(SOURCES_JS:src/js/%.js=run/lib/js/%.js)\
	$(SOURCES_JSON:src/json/%.json=run/lib/json/%.json)


DIST_WWW_ALL?=\
	$(SOURCES_HTML:src/html/%.html=dist/www/%.html)\
	$(SOURCES_XML:src/xml/%.xml=dist/www/%.html)\
	$(SOURCES_CSS:src/css/%.css=dist/www/lib/css/%.css)\
	$(SOURCES_CSS_JS:src/css/%.js=dist/www/lib/css/%.css)\
	$(SOURCES_JS:src/js/%.js=dist/www/lib/js/%.js)\
	$(SOURCES_JSON:src/json/%.json=dist/www/lib/json/%.json)

DIST_ALL+=$(DIST_WWW_ALL)
RUN_ALL+=$(RUN_WWW_ALL)
DIST_ALL+=$(DIST_WWW_ALL)
# EOF

