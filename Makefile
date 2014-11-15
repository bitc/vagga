RUSTC ?= rustc
CC ?= gcc
AR ?= ar

PREFIX ?= /usr
DESTDIR ?=
VAGGA_PATH_DEFAULT ?= $(PREFIX)/lib/vagga
NIX_PROFILES_SUPPORT ?= yes
export VAGGA_PATH_DEFAULT

ARGPARSELIB = rust-argparse/$(shell rustc --print-file-name rust-argparse/src/lib.rs)
QUIRELIB = rust-quire/$(shell rustc --print-file-name rust-quire/src/lib.rs)

all: quire argparse vagga libfake

vagga: $(ARGPARSELIB) $(QUIRELIB) src/*.rs src/*/*.rs libcontainer.a
	$(RUSTC) src/mod.rs -g -o $@ \
		-L rust-quire -L rust-argparse \
		$(if $(NIX_PROFILES_SUPPORT),--cfg nix_profiles,)

libcontainer.a: container.c
	$(CC) -c $< -o container.o -fPIC
	$(AR) rcs $@ container.o

libfake: inventory/libfake.so

inventory/libfake.so: fake.c
	$(CC) -fPIC -shared -ldl $< -o $@ $(CFLAGS) $(CPPFLAGS) $(LDFLAGS)

quire:
	make -C rust-quire quire-lib

argparse:
	make -C rust-argparse argparse-lib

install:
	install -d $(DESTDIR)$(PREFIX)/bin
	install -d $(DESTDIR)$(PREFIX)/lib/vagga
	install -m 755 vagga $(DESTDIR)$(PREFIX)/bin/vagga

	cp -r builders inventory $(DESTDIR)$(PREFIX)/lib/vagga/


.PHONY: all quire argparse libfake
