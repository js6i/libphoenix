#
# Makefile for libphoenix
#
# Copyright 2017, 2018 Phoenix Systems
#
# %LICENSE%
#

SIL ?= @
MAKEFLAGS += --no-print-directory --output-sync

#TARGET ?= arm-imx6ull
#TARGET ?= armv7-stm32-tiramisu
TARGET ?= ia32-qemu
#TARGET ?= riscv64

VARIANT ?= posix
#VARIANT ?= ansi

VERSION = 0.2
TOPDIR := $(CURDIR)
PREFIX_BUILD ?= ../_build/$(TARGET)
PREFIX_BUILD := $(abspath $(PREFIX_BUILD))
BUILD_DIR ?= $(PREFIX_BUILD)/$(notdir $(TOPDIR))
BUILD_DIR := $(abspath $(BUILD_DIR))

LIBNAME := libphoenix.a
LIB := $(BUILD_DIR)/$(LIBNAME)

include Makefile.targets

CFLAGS += -I"$(TOPDIR)/include"
CFLAGS += -DVERSION=\"$(VERSION)\"
CFLAGS += -fdata-sections -ffunction-sections
CFLAGS += -D_NO_WORDEXP
LDFLAGS += --gc-sections

SYSROOT := $(shell $(CC) $(CFLAGS) -print-sysroot)
MULTILIB_DIR := $(shell $(CC) $(CFLAGS) -print-multi-directory)
LIBC_INSTALL_DIR := $(SYSROOT)/lib/$(MULTILIB_DIR)
LIBC_INSTALL_NAMES := libc.a libm.a crt0.o libg.a
HEADERS_INSTALL_DIR := $(SYSROOT)/usr/include/

ifeq (/,$(SYSROOT))
	$(error Sysroot is not supported by Your toolchain. Use cross-toolchain to compile)
endif

HEADERS = $(shell find include -type f)

SRCS = 


all: $(LIB)

include $(VARIANT)/Makefile.inc

OBJS := $(patsubst $(TOPDIR)/%,$(BUILD_DIR)/%,$(abspath $(addsuffix .o, $(basename $(SRCS)))))

$(LIB): $(OBJS)
	@echo "\033[1;34mLD $@\033[0m"	
	@rm -rf "$@"
	$(SIL)$(AR) cqT -o $@ $(abspath $^) && echo "create $@\naddlib $@\nsave\nend" | $(AR) -M
	@($(SIZE) -t $(LIB) | sed 's/(ex.*//')

	@(echo "";\
	echo "=> libphoenix for [$(TARGET)] has been created";\
	echo "")



install: $(LIB) $(HEADERS)
	@echo "Installing into: $(LIBC_INSTALL_DIR)"; \
	mkdir -p "$(LIBC_INSTALL_DIR)" "$(HEADERS_INSTALL_DIR)"; \
	cp -a "$<" "$(LIBC_INSTALL_DIR)"; \
	for lib in $(LIBC_INSTALL_NAMES); do \
		if [ ! -e "$(LIBC_INSTALL_DIR)/$$lib" ]; then \
			ln -sf "$(LIBC_INSTALL_DIR)/$(LIBNAME)" "$(LIBC_INSTALL_DIR)/$$lib"; \
		fi \
	done; \
	for file in $(patsubst include/%, %, $(HEADERS)); do\
		base=`dirname $${file}`; \
		mkdir -p "$(HEADERS_INSTALL_DIR)/$${base}"; \
		install -p -m 644 include/$${file} $(HEADERS_INSTALL_DIR)/$${file};\
	done

uninstall:
	rm -rf "$(LIBC_INSTALL_DIR)/$(LIBNAME)"
	@for lib in $(LIBC_INSTALL_NAMES); do \
		rm -rf "$(LIBC_INSTALL_DIR)/$$lib"; \
	done
	@for file in $(HEADERS); do \
		rm -rf "$(HEADERS_INSTALL_DIR)/$${file}"; \
	done

clean:
	@rm -rf $(BUILD_DIR)



# include after all dependencies are set
include $(TOPDIR)/Makefile.rules

.PHONY: clean install uninstall
# DO NOT DELETE
