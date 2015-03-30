all: 	shtpl

shtpl:	shtpl.vala
	git describe --dirty > VERSION.vala
	sed -i 's/\(.*\)/static const string VERSION = "\1";/' VERSION.vala
	valac --pkg glib-2.0 --pkg gio-2.0 VERSION.vala shtpl.vala -o shtpl

clean:
	rm -f shtpl *.c *.o

.PHONY:	clean all
