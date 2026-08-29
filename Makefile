PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
INSTALL ?= install

.PHONY: install uninstall

install:
	$(INSTALL) -d $(DESTDIR)$(BINDIR)
	$(INSTALL) -m 0755 fapple $(DESTDIR)$(BINDIR)/fapple

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/fapple
