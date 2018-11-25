### Makefile
### Does all the magic automatically.
###
### Author: Nathan Campos <nathan@innoveworkshop.com>

# Directories.
TAGSDIR = tags
XC8DIR = /opt/microchip/xc8/v2.00
XC16DIR = /opt/microchip/xc16/v1.35

# Flags.
TFLAGS = --c-kinds=+defgmpstuvxz -V

# Utilities.
RM = rm -f
MKDIR = mkdir -p
CTAGS = ctags

all: $(TAGSDIR)/xc8 $(TAGSDIR)/xc16

$(TAGSDIR)/xc8/%: $(XC8DIR)/pic/include/%.h
	-echo -e "\033[1mBuilding tags for the 8-bit family\033[0m"
	$(MKDIR) $(TAGSDIR)/xc8
	$(CTAGS) $(TFLAGS) -o $@ $<

$(TAGSDIR)/xc16:
	-echo -e "\033[1mBuilding tags for the 16-bit family\033[0m"
	$(MKDIR) $(TAGSDIR)/xc16

clean:
	$(RM) -r $(TAGSDIR)

