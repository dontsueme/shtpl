all:	release/tinytpl

release/tinytpl: tinytpl
	$(shell git diff >/dev/null; git status >/dev/null)
	git describe --dirty > VERSION
	mkdir -p release
	sed s/VERSION/"`cat VERSION`"/ tinytpl > release/tinytpl
	chmod +x release/tinytpl

install: release/tinytpl
	install -m 755 release/tinytpl /usr/local/bin

uninstall:
	rm -fv /usr/local/bin/tinytpl

clean:
	[ -d release ] && rm -r release; rm -f VERSION

.PHONY: clean
