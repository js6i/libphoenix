SRCS += $(shell find posix/common -name \*.c)
SRCS += $(shell find posix/$(ARCH_DIR) -name \*.S -or -name \*.c)

ERR_INCS := errno.str.inc errno.tab.inc gaierr.str.inc gaierr.tab.inc

ERR_EXTRACT := sed -En -e '/^\s*\#\s*define\s+E\w+\s+[[:digit:]]+/{s/^[^d]*define\s+(\w+)\s+([[:digit:]]+).*/\2\t\1/;p;d}' \
 -e '/^\s*E\w+\s*=\s*-?[[:digit:]]+/{s/^\s*(\w+)\s*=\s*-?([[:digit:]]+).*/\2\t\1/;p;d}'

%/errno.list: $(HEADERS_INSTALL_DIR)/phoenix/errno.h $(TOPDIR)/include/errno.h
	@(printf "GEN %-24s  \n" "$(@F)")
	$(SIL)$(ERR_EXTRACT) $^ | sort -n > $@

%/gaierr.list: $(TOPDIR)/include/netdb.h
	@(printf "GEN %-24s  \n" "$(@F)")
	$(SIL)$(ERR_EXTRACT) $^ | sort -n > $@

%.str.inc: %.list Makefile
	@(printf "GEN %-24s  \n" "$(@F)")
	$(SIL)sed -e 's/^.*\t\(.*\)$$/"\1\\0"/' $< > $@

%.tab.inc: %.list Makefile
	@(printf "GEN %-24s  \n" "$(@F)")
	$(SIL)bash -c 'o=0; while read num name; do echo "{ $$num, $$o },"; o=$$((o+$${#name}+1)); done' < $< > $@

CFLAGS += -I"$(BUILD_DIR)/posix"

$(BUILD_DIR)/posix/common/string/strerror.o: $(patsubst %,$(BUILD_DIR)/posix/%,$(ERR_INCS))

