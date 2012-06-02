all:	release/tinytpl

release/tinytpl: tinytpl
	$(shell git describe --dirty > VERSION)
	$(shell mkdir -p release)
	$(shell sed s/VERSION/"`cat VERSION`"/ tinytpl > release/tinytpl)
	$(shell chmod +x release/tinytpl)

clean:
	$(shell [ -d release ] && rm -r release; rm -f VERSION)

.PHONY: clean
