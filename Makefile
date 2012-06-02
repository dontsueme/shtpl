all:	release/tinytpl

release/tinytpl: tinytpl
	$(shell git diff >/dev/null; git status >/dev/null)
	git describe --dirty > VERSION
	mkdir -p release
	sed s/VERSION/"`cat VERSION`"/ tinytpl > release/tinytpl
	chmod +x release/tinytpl

clean:
	[ -d release ] && rm -r release; rm -f VERSION

.PHONY: clean
