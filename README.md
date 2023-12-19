# TexDown.jl

TeXDown converts simple Markdown files into nice PDFs for printing via LaTeX. This package solves two niche problems I have:

1. I would like to compile Markdown into LaTeX that is very similar to what I myself would have written. The common advice for converting Markdown to LaTeX is to use [Pandoc](https://pandoc.org), however, the LaTeX produced by this process is borderline unintelligible (even if it does compile to a reasonable looking PDF). This makes it difficult to make edits, or incorporate into a separate LaTeX file, or share with collaborators.
2. I would like to be able to add a preamble, and ideally go directly from Markdown to PDF without having to muck around with LaTeX at all. This is useful for e.g. taking a simple todo list in Markdown and printing to PDF.

TeXDown is really just a fairly lightweight wrapper for [CommonMark.jl](https://github.com/MichaelHatherly/CommonMark.jl). The main additions are:

* CommonMark still produces a handful of odd LaTeX artifacts that TeXDown removes (e.g. `\par` at the end of each paragraph).
* Adds preambles for three of my common use cases: writing a research note, writing a todo list, and writing a recipe. 
* Apple Shortcuts scripts to convert Markdown with a just a few clicks, avoiding having to open Julia or LaTeX directly.

The [examples](examples/) folder contains several simple examples which should give a good overview of the style, formatting, and capabilities of TeXDown.

## Installation
These instructions are for macOS only. TeXDown should work on Windows but I haven't tested it. 

### Download Julia
Julia can be downloaded [here](https://julialang.org/downloads/), the latest version should be fine.

### Install TexDown
Open Julia and run
```julia
using Pkg
Pkg.add(url="https://github.com/johngolden/TeXDown.jl")
```

### Install LaTeX
The simplest way to install a lightweight LaTeX distribution is via Homebrew. If you don't already have Homebrew installed, open Terminal and run
```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Once you have Homebrew installed, run
```zsh
brew install --cask mactex-no-gui
```

### Add shortcuts
Note that most of these shortcuts assume you are using Julia 1.9.x and will need to be modified for different versions.

Once you've downloaded these shortcuts, they can be used by right-clicking a Markdown file and scrolling down to "Quick Actions". Then click "Customize" and select the TeXDown shortcuts you wish to add to the menu. Once they are added they will appear in the "Quick Actions" menu. The first time you run a shortcut you will likely need to grant permission for the shortcuts to run scripts, access files, etc. The output of the shortcut will be saved in the same folder as the Markdown file you're converting.

If you use one shortcut frequently, you can add a keyboard shortcut to activate it. For example, you could select a Markdown file and hit `ctrl-shift-P` to automatically create a todo list PDF. To add a keyboard shortcut, open the shortcut (by double-clicking it) in the Shortcuts app, then click the "ℹ︎" with a circle around it in the upper right corner of the window. Enter the desired keyboard shortcut in the "Run with:" box.

**Markdown to PDF**
* [Todo list](https://www.icloud.com/shortcuts/447956dcd2db44db861ba56869fb1631)
* [Research note](https://www.icloud.com/shortcuts/45c416490ffd4f0eb9b099ae7919bd19)
* [Recipe](https://www.icloud.com/shortcuts/24b1beeefbd84abbb282bb011a3db4a1)

**Markdown to LaTeX**
* [Todo list](https://www.icloud.com/shortcuts/4e39d211b3e5450898c92e9d96f2890d)
* [Research note](https://www.icloud.com/shortcuts/d94943b28ee04d4daee6c2d6ca10088d)
* [Recipe](https://www.icloud.com/shortcuts/902037aa4bcf4e64aeae77fa2816222d)
* [No Preamble](https://www.icloud.com/shortcuts/967334bb0872405db3c95d7124d03bce)


**Print Recipe PDFs**

The `recipe` template defaults to 8.5" x 5.5" PDFs (meant to be printed out and affixed to a 5x8 index card). The following script prepares these PDFs for printing on a standard 8.5" x 11" piece of paper. This can be done in three ways:

1. Take two recipes which each fit on a single 8.5" x 5.5" page and combine them into a single 8.5" x 11" page.
2. Take one recipe which covers two 8.5" x 5.5" pages and combines them into a single 8.5" x 11" page.
3. Take a single recipe which fits on a single 8.5" x 5.5" page and add whitespace so that it prints nicely on an 8.5" x 11" page.

In each case the resulting combined PDF is saved to the users Desktop under `print.pdf`.

These three options are all combined into a single shortcut:

* [Combine recipe PDFs](https://www.icloud.com/shortcuts/eca3563e1407489eb119ddf4c6faa13b)



## Usage
TeXDown was designed to be predominantly used via Apple Shortcuts, however it can of course be used in Julia itself. Here are the basic functions, see the documentation in [main.jl](src/main.jl) for slightly more information.

```julia
make_tex(md_content)
```
Turn `md_content` -- either a Markdown file or string -- into LaTeX without a preamble.

```julia
make_tex(md_content, template)
```
Convert the contents of `md_content` into LaTeX with `template`. Currently accepted options for `template` are `research_note`, `todo_list`, and `recipe`.

```julia
make_pdf(md_content, template)
```
Convert the contents of `md_content` into a PDF with `template`, and deletes all LaTeX auxiliary files. 
