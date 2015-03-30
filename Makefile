all:	release/shtpl release/shtplv

release/shtpl: shtpl
	$(shell git diff >/dev/null; git status >/dev/null)
	git describe --dirty > VERSION
	mkdir -p release
	sed s/VERSION/"`cat VERSION`"/ shtpl > release/shtpl
	chmod +x release/shtpl

release/shtplv: vala/shtpl
	cp vala/shtpl release/shtplv

vala/shtpl: vala/shtpl.vala
	make -C vala

install: release/shtpl release/shtplv
	install -m 755 release/shtpl  /usr/local/bin
	install -m 755 release/shtplv /usr/local/bin

uninstall:
	rm -fv /usr/local/bin/shtpl /usr/local/bin/shtplv

clean:
	[ -d release ] && rm -r release; rm -f VERSION
	make -C vala clean

.PHONY: clean
