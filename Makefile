all:	release/tinytpl

release/tinytpl: tinytpl
	git describe --dirty > VERSION
	mkdir -p release
	sed s/VERSION/"`cat VERSION`"/ tinytpl > release/tinytpl
	chmod +x release/tinytpl

clean:
	[ -d release ] && rm -r release; rm -f VERSION

.PHONY: clean
