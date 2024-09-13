DIST_WWW_ALL?=\
	$(SOURCES_HTML:src/html/%.html=dist/www/%.html)\
	$(SOURCES_XML:src/xml/%.xml=dist/www/%.html)\
	$(SOURCES_CSS:src/css/%.css=dist/www/lib/css/%.css)\
	$(SOURCES_JS:src/js/%.js=dist/www/lib/js/%.js)\
	$(SOURCES_JSON:src/json/%.json=dist/www/lib/json/%.json)

DIST_ALL+=$(DIST_WWW_ALL)
# EOF

