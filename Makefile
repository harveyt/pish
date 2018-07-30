# -*- Makefile -*-

BINDIR	= /usr/local/bin
LIBDIR	= /usr/local/lib/pish
EXECDIR	= /usr/local/lib/pish/exec

LIBS	= $(filter-out lib/pish/exec, $(wildcard lib/pish/*))
EXECS	= $(wildcard lib/pish/exec/*)
FILES	= bin/pish $(LIBS)

# --------------------------------------------------------------------------------
# Execs

CURL		= curl -L -J
TAR		= tar -v
UNZIP		= unzip
DOWNLOADS	= $(HOME)/Downloads

_1PASS_VERSION	= 1.1.0
_1PASS_URL	= https://github.com/harveyt/1pass/archive/$(_1PASS_VERSION).tar.gz
_1PASS_DL	= $(DOWNLOADS)/1pass.tar.gz
_1PASS_DIR	= $(DOWNLOADS)/1pass
_1PASS_BIN	= $(_1PASS_DIR)/1pass-$(_1PASS_VERSION)/1pass

OP_VERSION	= 0.5.1
OP_SYSTEM	= darwin_amd64
OP_URL		= https://cache.agilebits.com/dist/1P/op/pkg/v$(OP_VERSION)/op_$(OP_SYSTEM)_v$(OP_VERSION).zip
OP_DL		= $(DOWNLOADS)/op.zip
OP_DIR		= $(DOWNLOADS)/op
OP_BIN		= $(DOWNLOADS)/op/op

JQ_VERSION	= 1.5
JQ_SYSTEM	= osx-amd64
JQ_URL		= https://github.com/stedolan/jq/releases/download/jq-$(JQ_VERSION)/jq-$(JQ_SYSTEM)
JQ_DIR		= $(DOWNLOADS)/jq
JQ_DL		= $(DOWNLOADS)/jq/jq
JQ_BIN		= $(DOWNLOADS)/jq/jq

# --------------------------------------------------------------------------------
# Targets

.DEFAULT: install

install: uninstall
	./install_files $(BINDIR) $(LIBDIR) $(FILES)
	mkdir -p $(EXECDIR)
	[[ "$(EXECS)" ]] && cp -a $(EXECS) $(EXECDIR)

uninstall:
	rm -f $(BINDIR)/pish
	rm -rf $(LIBDIR)

update: update-1pass update-op update-jq

update-1pass:
	mkdir -p $(_1PASS_DIR)
	mkdir -p lib/pish/exec
	$(CURL) -o $(_1PASS_DL) $(_1PASS_URL)
	$(TAR) -C $(_1PASS_DIR) -zxf $(_1PASS_DL)
	cp $(_1PASS_BIN) lib/pish/exec/1pass
	chmod a+rx lib/pish/exec/1pass

update-op:
	mkdir -p $(OP_DIR)
	mkdir -p lib/pish/exec
	$(CURL) -o $(OP_DL) $(OP_URL)
	$(UNZIP) -d $(OP_DIR) -o -x $(OP_DL)
	cp $(OP_BIN) lib/pish/exec/op
	chmod a+rx lib/pish/exec/op

update-jq:
	mkdir -p $(JQ_DIR)
	mkdir -p lib/pish/exec
	$(CURL) -o $(JQ_DL) $(JQ_URL)
	cp $(JQ_BIN) lib/pish/exec/jq
	chmod a+rx lib/pish/exec/jq

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
