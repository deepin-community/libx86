OBJECTS = x86-common.o
CFLAGS ?= -O2 -Wall -DDEBUG -g
LIBDIR ?= /usr/lib

ifeq ($(BACKEND),x86emu)
	OBJECTS += thunk.o x86emu/decode.o x86emu/debug.o x86emu/fpu.o \
	x86emu/ops.o x86emu/ops2.o x86emu/prim_ops.o x86emu/sys.o
else
	OBJECTS += lrmi.o
endif

ifeq ($(LIBRARY),shared)
	CFLAGS += -fPIC
endif

default:
	$(MAKE) LIBRARY=static static
	$(MAKE) objclean
	$(MAKE) LIBRARY=shared shared

static: $(OBJECTS)
	$(AR) cru libx86.a $(OBJECTS)

shared: $(OBJECTS)
	$(CC) $(CFLAGS) -o libx86.so.1 -shared -Wl,-soname,libx86.so.1 $(OBJECTS)

objclean:
	$(MAKE) -C x86emu clean
	rm -f *.o *~

clean: objclean
	rm -f *.so.1 *.a

install: libx86.so.1
	install -D libx86.so.1 $(DESTDIR)$(LIBDIR)/libx86.so.1
	install -D libx86.a $(DESTDIR)$(LIBDIR)/libx86.a
	ln -sf libx86.so.1 $(DESTDIR)$(LIBDIR)/libx86.so
	install -p -m 0644 -D lrmi.h $(DESTDIR)/usr/include/libx86.h
