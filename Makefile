PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

.PHONY: install uninstall

# Copies fapple to $(BINDIR), occupies ~/Library/Trial and /Library/Trial,
# and installs login + boot auto-mount jobs. Needs sudo for /Library/Trial.
install:
	./fapple install

uninstall:
	-./fapple disable-auto-mount
	-./fapple unmount
	rm -f $(DESTDIR)$(BINDIR)/fapple
