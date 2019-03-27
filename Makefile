# -*- Makefile -*-

PREFIX			= /usr/local
BINDIR			= bin
LIBDIR			= lib/pish
EXECDIR			= lib/pish/exec

LIBS			= $(filter-out $(EXECDIR), $(wildcard lib/pish/*))
FILES			= bin/pish $(LIBS)

MAC_EXECDIR		= $(EXECDIR)/mac
MAC_EXECS		= $(wildcard $(MAC_EXECDIR)/*)

WIN10_EXECDIR		= $(EXECDIR)/win10
WIN10_EXECS		= $(wildcard $(WIN10_EXECDIR)/*)

# --------------------------------------------------------------------------------
# Execs

CURL			= curl -L -J -\#
TAR			= tar -v
UNZIP			= unzip
UPDATE_DIR		= $(HOME)/tmp/pish-update

# --------------------------------------------------------------------------------
# Mac Helpers

MAC_1PASS_VERSION	= 1.2.1
MAC_1PASS_URL		= https://github.com/harveyt/1pass/archive/$(MAC_1PASS_VERSION).tar.gz
MAC_1PASS_DL		= $(UPDATE_DIR)/mac/1pass.tar.gz
MAC_1PASS_DIR		= $(UPDATE_DIR)/mac/1pass
MAC_1PASS_BIN		= $(MAC_1PASS_DIR)/1pass-$(MAC_1PASS_VERSION)/1pass

MAC_OP_VERSION		= 0.5.5
MAC_OP_SYSTEM		= darwin_amd64
MAC_OP_URL		= https://cache.agilebits.com/dist/1P/op/pkg/v$(MAC_OP_VERSION)/op_$(MAC_OP_SYSTEM)_v$(MAC_OP_VERSION).zip
MAC_OP_DL		= $(UPDATE_DIR)/mac/op.zip
MAC_OP_DIR		= $(UPDATE_DIR)/mac/op
MAC_OP_BIN		= $(UPDATE_DIR)/mac/op/op

MAC_JQ_VERSION		= 1.6
MAC_JQ_SYSTEM		= osx-amd64
MAC_JQ_URL		= https://github.com/stedolan/jq/releases/download/jq-$(MAC_JQ_VERSION)/jq-$(MAC_JQ_SYSTEM)
MAC_JQ_DIR		= $(UPDATE_DIR)/mac/jq
MAC_JQ_DL		= $(UPDATE_DIR)/mac/jq/jq
MAC_JQ_BIN		= $(UPDATE_DIR)/mac/jq/jq

# --------------------------------------------------------------------------------
# Windows 10 Helpers

WIN10_1PASS_VERSION	= 1.2.1
WIN10_1PASS_URL		= https://github.com/harveyt/1pass/archive/$(WIN10_1PASS_VERSION).tar.gz
WIN10_1PASS_DL		= $(UPDATE_DIR)/win10/1pass.tar.gz
WIN10_1PASS_DIR		= $(UPDATE_DIR)/win10/1pass
WIN10_1PASS_BIN		= $(WIN10_1PASS_DIR)/1pass-$(WIN10_1PASS_VERSION)/1pass

WIN10_OP_VERSION	= 0.5.5
WIN10_OP_SYSTEM		= windows_amd64
WIN10_OP_URL		= https://cache.agilebits.com/dist/1P/op/pkg/v$(WIN10_OP_VERSION)/op_$(WIN10_OP_SYSTEM)_v$(WIN10_OP_VERSION).zip
WIN10_OP_DL		= $(UPDATE_DIR)/win10/op.zip
WIN10_OP_DIR		= $(UPDATE_DIR)/win10/op
WIN10_OP_BIN		= $(UPDATE_DIR)/win10/op/op.exe

WIN10_JQ_VERSION	= 1.6
WIN10_JQ_SYSTEM		= win64
WIN10_JQ_URL		= https://github.com/stedolan/jq/releases/download/jq-$(WIN10_JQ_VERSION)/jq-$(WIN10_JQ_SYSTEM).exe
WIN10_JQ_DIR		= $(UPDATE_DIR)/win10/jq
WIN10_JQ_DL		= $(UPDATE_DIR)/win10/jq/jq.exe
WIN10_JQ_BIN		= $(UPDATE_DIR)/win10/jq/jq.exe

# --------------------------------------------------------------------------------
# Targets

.DEFAULT: install

.NOTPARALLEL: install

install: uninstall install-common install-mac install-win10

install-common:
	./install_files $(PREFIX)/$(BINDIR) $(PREFIX)/$(LIBDIR) $(FILES)
	mkdir -p $(PREFIX)/$(EXECDIR)

install-mac:
	mkdir -p $(PREFIX)/$(MAC_EXECDIR)
	[[ "$(MAC_EXECS)" ]] && cp -a $(MAC_EXECS) $(PREFIX)/$(MAC_EXECDIR)

install-win10:
	mkdir -p $(PREFIX)/$(WIN10_EXECDIR)
	[[ "$(WIN10_EXECS)" ]] && cp -a $(WIN10_EXECS) $(PREFIX)/$(WIN10_EXECDIR)

uninstall:
	rm -f $(PREFIX)/$(BINDIR)/pish
	rm -rf $(PREFIX)/$(LIBDIR)

.NOTPARALLEL: update

update: update-clean update-mac update-win10

update-clean:
	rm -rf $(UPDATE_DIR)

update-mac: update-mac-1pass update-mac-op update-mac-jq

update-mac-1pass:
	mkdir -p $(MAC_1PASS_DIR)
	mkdir -p $(MAC_EXECDIR)
	$(CURL) -o $(MAC_1PASS_DL) $(MAC_1PASS_URL)
	$(TAR) -C $(MAC_1PASS_DIR) -zxf $(MAC_1PASS_DL)
	cp $(MAC_1PASS_BIN) $(MAC_EXECDIR)/1pass
	chmod a+rx $(MAC_EXECDIR)/1pass

update-mac-op:
	mkdir -p $(MAC_OP_DIR)
	mkdir -p $(MAC_EXECDIR)
	$(CURL) -o $(MAC_OP_DL) $(MAC_OP_URL)
	$(UNZIP) -d $(MAC_OP_DIR) -o -x $(MAC_OP_DL)
	cp $(MAC_OP_BIN) $(MAC_EXECDIR)/op
	chmod a+rx $(MAC_EXECDIR)/op

update-mac-jq:
	mkdir -p $(MAC_JQ_DIR)
	mkdir -p $(MAC_EXECDIR)
	$(CURL) -o $(MAC_JQ_DL) $(MAC_JQ_URL)
	cp $(MAC_JQ_BIN) $(MAC_EXECDIR)/jq
	chmod a+rx $(MAC_EXECDIR)/jq

update-win10: update-win10-1pass update-win10-op update-win10-jq

update-win10-1pass:
	mkdir -p $(WIN10_1PASS_DIR)
	mkdir -p $(WIN10_EXECDIR)
	$(CURL) -o $(WIN10_1PASS_DL) $(WIN10_1PASS_URL)
	$(TAR) -C $(WIN10_1PASS_DIR) -zxf $(WIN10_1PASS_DL)
	cp $(WIN10_1PASS_BIN) $(WIN10_EXECDIR)/1pass
	chmod a+rx $(WIN10_EXECDIR)/1pass

update-win10-op:
	mkdir -p $(WIN10_OP_DIR)
	mkdir -p $(WIN10_EXECDIR)
	$(CURL) -o $(WIN10_OP_DL) $(WIN10_OP_URL)
	$(UNZIP) -d $(WIN10_OP_DIR) -o -x $(WIN10_OP_DL)
	cp $(WIN10_OP_BIN) $(WIN10_EXECDIR)/op.exe
	chmod a+rx $(WIN10_EXECDIR)/op.exe

update-win10-jq:
	mkdir -p $(WIN10_JQ_DIR)
	mkdir -p $(WIN10_EXECDIR)
	$(CURL) -o $(WIN10_JQ_DL) $(WIN10_JQ_URL)
	cp $(WIN10_JQ_BIN) $(WIN10_EXECDIR)/jq.exe
	chmod a+rx $(WIN10_EXECDIR)/jq.exe

release:
	$(MAKE) release-create
	$(MAKE) release-publish

release-create:
	@version=$(VERSION);					\
	if [[ "$$(git status --porcelain)" != "" ]]; then	\
		git status;					\
		echo "\nerror: Commit all changes first!" >&2;	\
		exit 1;						\
	fi;							\
	if [[ "$$version" == "" ]]; then			\
		git tag --column;				\
		echo "\nerror: Set VERSION variable!" >&2;	\
		exit 1;						\
	fi;							\
	echo "Releasing version $$version";			\
	git tag $$version
	$(MAKE) install

release-publish:
	git push
	git push --tags
