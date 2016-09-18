#----------------------------------------------------------------------------#
# Main build variables                                                       #
#----------------------------------------------------------------------------#
PLUGIN = commentable
LISTFILE = build.lst
VIMBALL = $(PLUGIN).vmb

#----------------------------------------------------------------------------#
# Source files                                                               #
#----------------------------------------------------------------------------#
SOURCE  = $(shell find plugin -type f)
SOURCE += $(shell find autoload -type f)
SOURCE += doc/commentable.txt

#----------------------------------------------------------------------------#
# Temporary test files                                                       #
#----------------------------------------------------------------------------#
TEMPTESTS  = $(shell find tests -type f \( -name '*.out' -o -name '*.dif' \) )
TEMPTESTS += regression.trc

#----------------------------------------------------------------------------#
# Shell commands                                                             #
#----------------------------------------------------------------------------#
RM = rm
VIM = vim
PRINTF = printf

#----------------------------------------------------------------------------#
# Special variables and rules for rules section                              #
#----------------------------------------------------------------------------#
.DEFAULT_GOAL = $(VIMBALL)
.PHONY: clean

#----------------------------------------------------------------------------#
# Rules                                                                      #
#----------------------------------------------------------------------------#
$(VIMBALL): $(LISTFILE)
	$(VIM) $(LISTFILE) \
		-u NORC \
		-c 'let g:vimball_home="."' \
		-c 'execute "%MkVimball!" . "$(PLUGIN)"' \
		-c 'quitall!'

$(LISTFILE): $(SOURCE)
	$(PRINTF) '%s\n' $(foreach I,$(SOURCE),"$(I)") >| $(LISTFILE)

clean:
	@-$(RM) $(VIMBALL) $(LISTFILE) $(TEMPTESTS) GTAGS GRTAGS GPATH tags
