all: 	shtpl

shtpl:	shtpl.vala
	valac --pkg glib-2.0 --pkg gio-2.0 shtpl.vala -o shtpl

clean:
	rm -f shtpl *.c *.o

.PHONY:	clean all
