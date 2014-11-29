
PREFIX ?= /usr/local

install: bin/g
	cp $< $(PREFIX)/$<

uninstall:
	rm -f $(PREFIX)/bin/g

.PHONY: install uninstall