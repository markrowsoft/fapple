PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
FAPPLE ?= $(firstword $(wildcard $(DESTDIR)$(BINDIR)/fapple) ./fapple)
TOUCH ?= /usr/bin/touch
USER_TRIAL ?= $(HOME)/Library/Trial
SYSTEM_TRIAL ?= /Library/Trial

.PHONY: install uninstall test

# Copies fapple to $(BINDIR), occupies ~/Library/Trial and /Library/Trial,
# and installs login + boot auto-mount jobs. Needs sudo for /Library/Trial.
# If fapple is already installed, only occupies this user's ~/Library/Trial.
install:
	./fapple install

uninstall:
	-./fapple disable-auto-mount
	-./fapple unmount
	rm -f $(DESTDIR)$(BINDIR)/fapple

# After sudo make install (and after logout/login or reboot).
# Both Trial mounts must reject writes.
test:
	$(FAPPLE) status
	@echo "== probing $(USER_TRIAL) =="
	@if $(TOUCH) "$(USER_TRIAL)/.fapple-test"; then \
		echo "FAIL: $(USER_TRIAL) is writable"; exit 1; \
	else \
		echo "OK: $(USER_TRIAL) blocked"; \
	fi
	@echo "== probing $(SYSTEM_TRIAL) =="
	@if sudo $(TOUCH) "$(SYSTEM_TRIAL)/.fapple-test"; then \
		echo "FAIL: $(SYSTEM_TRIAL) is writable"; exit 1; \
	else \
		echo "OK: $(SYSTEM_TRIAL) blocked"; \
	fi
