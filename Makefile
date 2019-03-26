# -*- Makefile -*-

PREFIX			= /usr/local
BINDIR			= bin
LIBDIR			= lib/pish
EXECDIR			= lib/pish/exec

LIBS			= $(filter-out $(EXECDIR), $(wildcard lib/pish/*))
FILES			= bin/pish $(LIBS)

MAC_EXECDIR		= $(EXECDIR)/mac
MAC_EXECS		= $(wildcard $(MAC_EXECDIR)/*)

# --------------------------------------------------------------------------------
# Execs

CURL			= curl -L -J
TAR			= tar -v
UNZIP			= unzip
DOWNLOADS		= $(HOME)/Downloads

MAC_1PASS_VERSION	= 1.1.0
MAC_1PASS_URL		= https://github.com/harveyt/1pass/archive/$(_1PASS_VERSION).tar.gz
MAC_1PASS_DL		= $(DOWNLOADS)/1pass.tar.gz
MAC_1PASS_DIR		= $(DOWNLOADS)/1pass
MAC_1PASS_BIN		= $(_1PASS_DIR)/1pass-$(_1PASS_VERSION)/1pass

MAC_OP_VERSION		= 0.5.1
MAC_OP_SYSTEM		= darwin_amd64
MAC_OP_URL		= https://cache.agilebits.com/dist/1P/op/pkg/v$(MAC_OP_VERSION)/op_$(MAC_OP_SYSTEM)_v$(MAC_OP_VERSION).zip
MAC_OP_DL		= $(DOWNLOADS)/mac-op.zip
MAC_OP_DIR		= $(DOWNLOADS)/mac-op
MAC_OP_BIN		= $(DOWNLOADS)/mac-op/op

MAC_JQ_VERSION		= 1.5
MAC_JQ_SYSTEM		= osx-amd64
MAC_JQ_URL		= https://github.com/stedolan/jq/releases/download/jq-$(MAC_JQ_VERSION)/jq-$(MAC_JQ_SYSTEM)
MAC_JQ_DIR		= $(DOWNLOADS)/mac-jq
MAC_JQ_DL		= $(DOWNLOADS)/mac-jq/jq
MAC_JQ_BIN		= $(DOWNLOADS)/mac-jq/jq

# --------------------------------------------------------------------------------
# Targets

.DEFAULT: install

install: uninstall install-common install-mac

install-common:
	./install_files $(PREFIX)/$(BINDIR) $(PREFIX)/$(LIBDIR) $(FILES)
	mkdir -p $(PREFIX)/$(EXECDIR)

install-mac:
	mkdir -p $(PREFIX)/$(MAC_EXECDIR)
	[[ "$(MAC_EXECS)" ]] && cp -a $(MAC_EXECS) $(PREFIX)/$(MAC_EXECDIR)

uninstall:
	rm -f $(PREFIX)/$(BINDIR)/pish
	rm -rf $(PREFIX)/$(LIBDIR)

update: update-mac

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
