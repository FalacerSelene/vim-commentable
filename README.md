Commentable
===========

Version: 0.1.0

1. [Introduction](#introduction)
2. [Installation](#installation)
  1. [Requirements](#requirements)
  2. [Installing old-style](#install-old)
  3. [Install from Vimball](#install-vimball)
  4. [Install with Pathogen](#install-pathogen)
  5. [Install with Vundle](#install-vundle)
  6. [Install as a Package](#install-package)
3. [Quickstart](#quickstart)
4. [Configuration](#configuration)
5. [Contact](#contact)
6. [Licence](#licence)

## 1\. Introduction <!-- {{{1 -->
<a name="introduction"></a>

Commentable is a [Vim][vim] plugin that provides a set of commands and
functions that make it easy to use block (walled) comments across various
languages.

Although all languages offer a commenting feature, and may offer block
comments in addition to line comments, it's often preferred by style guidlines
to write more visually distinct comments as follows -- using C comments:

```c
/*********************************************************************/
/* Important and easily visible information.                         */
/*********************************************************************/
```

These "walled" comment blocks are a pain to rewrite manually, with the closing
boundary changing position and the need to reflow the lines arising.
Commentable provides a series of bindings and commands making this a single
action job.

Commentable integrates neatly with [vim-repeat][repeat]'s extensible .
command.

## 2\. Installation <!-- {{{1 -->
<a name="installation"></a>

### 2.1\. Requirements <!-- {{{2 -->
<a name="requirements"></a>

Commentable assumes a version of Vim compiled with the `normal` feature set.
Some vital features that are required are `eval` and `user_commands`.
Commentable requires a version of Vim of at least 7.4.

### 2.2\. Installing old-style <!-- {{{2 -->
<a name="install-old"></a>

Once you have a clone of this repo, copy the contents of each of the
directories (excluding "tests") in the repo into an identically named
directory in your vim config directory: on GNU/Linux this is ~/.vim; on
Windows, this is C:/users/&lt;username&gt;/.vim/. A shell command for achiving
this on GNU/Linux is:

```sh
find . -maxdepth 1 -type d -a \! -name tests -exec cp -r \{} ~/.vim/ \;
```

This assumes a posix compliant version of find. If you use a non-posix find,
you probably already know enough to generate an equivalent command for your
system.

### 2.3\. Installing from vimball <!-- {{{2 -->
<a name="install-vimball"></a>

In order to create a vimball for installing this plugin, run `make` in the
base directory. This will create a file named commentable.vmb. Once you have
this file, run:

```sh
vim commentable.vba
:so %
:q
```

to install the plugin.

### 2.4\. Installing with Pathogen <!-- {{{2 -->
<a name="install-pathogen"></a>

If you already have [Pathogen][pathogen] working then skip
[Step 1](#install-pathogen-step1) and go to
[Step 2](#install-pathogen-step2).

#### 2.4.1\. Step 1: Install pathogen <!-- {{{3 -->
<a name="#install-pathogen-step1"></a>

First, install [Pathogen][pathogen] so that it's easy to install Commentable.
Do this in your terminal so that you get the `pathogen.vim` file and the
directories it needs:

```sh
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
```

Then, add this to your `~/.vimrc`:
```vim
execute pathogen#infect()
```

#### 2.4.2\. Step 2: Install Commentable as a Pathogen Bundle <!-- {{{3 -->
<a name="install-pathogen-step2"></a>

You now have pathogen installed and should clone Commentable into into
`~/.vim/bundle`.

Once you have followed these steps than Commentable is installed:

1. Created both the `~/.vim/autoload` and `~/.vim/bundle` directories.
2. Added the `execute pathogen#infect()` line to your `~/.vimrc` file
3. Did the `git clone` of Commentable inside `~/.vim/bundle`
4. Have permissions to access all of these directories.

### 2.5\. Installing with Vundle <!-- {{{2 -->
<a name="install-vundle"></a>

#### 2.5.1\. Step 1: Install Vundle <!-- {{{3 -->
<a name="install-vundle-step1"></a>

[Vundle][vundle] uses the same style of managing plugins as
[Pathogen][pathogen] - that is, keeping every part of the plugin separated
within the "bundle" directory and adding it to Vim's runtime path. However,
Vundle makes it easy to install new plugins and to keep plugins updated
without having to manually clone or pull each one.

To install Vundle, run the following commands:

```sh
mkdir -p ~/.vim/bundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

Then, add the following lines at the top of your vimrc:

```vim
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

call vundle#end()

filetype plugin indent on
```

All plugins added between the #start and #end calls will be installed or
updated as necessary with the command *PluginInstall*.

#### 2.5.2\. Step 2: Install Commentable as a Vundle Plugin <!-- {{{3 -->
<a name="install-vundle-step2"></a>

To install Commentable, simply add the line:

```vim
Plugin 'fi-vim/commentable.vim'
```

and run *PluginInstall*.

### 2.5\. Installing as a Package <!-- {{{2 -->
<a name="install-package"></a>

If you have a Vim (not Neovim) of version 8 or later then you can use the
package interface to install Commentable.

Create the following directory tree in your .vim config directory:

.vim/pack/&lt;packagename&gt;/start/

where &lt;packagename&gt; is a name for this package (collection of plugins).
One possible scheme for naming packages is by author on Github, but the name
chosen will not affect plugin installation.

Inside the start/ directory, take a clone of this repository:

```sh
git clone http://github.com/galtish/vim-commentable
```

And that's all you need to do - the plugin is now installed!

## 3\. Quickstart <!-- {{{1 -->
<a name="quickstart"></a>

If all you want is to have some nice comment blocks, then add the following
command to your vimrc, or run it yourself when starting vim:

```vim
CommentableSetDefaultStyle
```

Once this is done, you can run

```vim
CommentableReformat
```

With your cursor on the block in question to prettify it, splitting the
comment body over lines correctly and aligning the comment walls.

Also exposed is the command:

```vim
CommentableCreate
```

*Create* embeds the current line of text within a new comment block, reflowing
it across multiple lines as necessary. It also accept a range, enclosing the
ranged-over lines of text in a comment block.

## 4\. Configuration <!-- {{{1 -->
<a name="configuration"></a>

If the default styles don't suit your language, preferences or other
requirements, then you can define your own comment styles at either a
per-buffer or global level.

In order to set a new global style, assign a 3-valued list to the variable
g:CommentableBlockStyle. The values of this list are, in turn, the left-hand
edge of the block, the top and bottom edges, and the right hand edge of the
desired block.

For example, if you set:

```vim
let g:CommentableBlockStyle = ['a', 'o', 'e']
```

Then resulting comment blocks will look like this:

```c
aooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooe
a Actual comment text here.                                        e
aooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooe
```

Obviously this is unlikely to be a real comment in your preferred language!

Elements of this list may also be more than one element long, which has the
following effect:

```vim
let g:CommentableBlockStyle = ['/*', 'xo', '*/']
```

```c
/*xoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxo*/
/* Actual comment text here.                                      */
/*xoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxo*/
```

This same variable may be set on a per-buffer level, in which case it is used
in preferrence to the global value. One of the recommended ways to use
Commentable is to set per-buffer values of this variable using either filetype
autocommands, or using ftplugin/&lt;filetype&gt;.vim files in your vim
directory.

```vim
let g:CommentableBlockStyle = ['/*', '*', '*/']
autocmd Filetype *.pl let b:CommentableBlockStyle = ['#-', '-', '-#']
```

In code.c:

```c
/******************************************************************/
/* Some very important function description text.                 */
/******************************************************************/
```

In code.pl:

```perl
#------------------------------------------------------------------#
#- An explanation of design choices in the following code.        -#
#------------------------------------------------------------------#
```

This section has only covered the simplest configuration of Commentable - to
see all the possible configuration parameters, please read the Vim help doc
after installing.

```vim
help commentable
```

## 5\. Contact <!-- {{{1 -->
<a name="contact"></a>

Please email all bugs report and feature suggestions to:

&lt; mj dot git plus commentable at fastmail dot com &gt;

## 6\. Licence <!-- {{{1 -->
<a name="licence"></a>

As per convention, Commentable is licenced under the term of the [Vim
licence][vim-lic], and may also be bound by the Neovim licence when run as a
[Neovim][neovim] plugin instead.

<!-- Links {{{1 -->

[vim]: http://www.vim.org/
[pathogen]: http://github.com/tpope/vim-pathogen
[neovim]: http://neovim.io/
[vim-lic]: http://vimdoc.sourceforge.net/htmldoc/uganda.html#license
[repeat]: http://github.com/tpope/vim-repeat
[vundle]: http://github.com/VundleVim/Vundle.vim
[tutor]: http://github.com/fmoralesc/vim-tutor-mode

<!--
vim:tw=78:expandtab:
-->
