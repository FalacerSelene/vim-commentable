#----------------------------------------------------------------------------#
# Main build variables                                                       #
#----------------------------------------------------------------------------#
PLUGIN   = commentable
LISTFILE = build.lst
VIMBALL  = $(PLUGIN).vmb

#----------------------------------------------------------------------------#
# Source files                                                               #
#----------------------------------------------------------------------------#
SOURCE  = $(shell find plugin -type f)
SOURCE += $(shell find autoload -type f)
SOURCE += doc/commentable.txt

#----------------------------------------------------------------------------#
# Temporary test files                                                       #
#----------------------------------------------------------------------------#
TEMPTESTS  = $(shell find tests -type f \( -name '*.out' -o -name '*.diff' \) )
TEMPTESTS += regression.trc

#----------------------------------------------------------------------------#
# Shell commands                                                             #
#----------------------------------------------------------------------------#
RM     = rm -f
VIM    = vim
PRINTF = printf

#----------------------------------------------------------------------------#
# Special variables and rules for rules section                              #
#----------------------------------------------------------------------------#
.DEFAULT_GOAL = $(VIMBALL)
.PHONY: clean test install test-clean

#----------------------------------------------------------------------------#
# Rules                                                                      #
#----------------------------------------------------------------------------#
$(VIMBALL): $(LISTFILE)
	$(VIM) $(LISTFILE) \
		-c 'let g:vimball_home="."' \
		-c 'execute "%MkVimball!" . "$(PLUGIN)"' \
		-c 'quitall!'

$(LISTFILE): $(SOURCE)
	@$(PRINTF) '%s\n' $(foreach I,$(SOURCE),"$(I)") >| $(LISTFILE)

install: $(VIMBALL)
	$(VIM) $(VIMBALL) \
		-c 'source %' \
		-c 'quitall!'
	@$(PRINTF) '%s\n' 'Installed - you will need to update helptags manually!'

test:
	./run-regressions --suite external

test-clean:
	@-$(RM) $(TEMPTESTS)

clean: test-clean
	@-$(RM) $(VIMBALL)
	@-$(RM) $(LISTFILE)
