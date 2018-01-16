# -*- Makefile -*-

BINDIR	= /usr/local/bin
LIBDIR	= /usr/local/lib/pish
LIBS	= $(wildcard lib/pish/*)
FILES	= bin/pish $(LIBS)

.DEFAULT: install

install: uninstall
	./install_files $(BINDIR) $(LIBDIR) $(FILES)

uninstall:
	rm -f $(BINDIR)/pish
	rm -rf $(LIBDIR)

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
