all:	release/shtpl

release/shtpl: shtpl
	$(shell git diff >/dev/null; git status >/dev/null)
	git describe --dirty > VERSION
	mkdir -p release
	sed s/VERSION/"`cat VERSION`"/ shtpl > release/shtpl
	chmod +x release/shtpl

install: release/shtpl
	install -m 755 release/shtpl /usr/local/bin

uninstall:
	rm -fv /usr/local/bin/shtpl

clean:
	[ -d release ] && rm -r release; rm -f VERSION

.PHONY: clean
