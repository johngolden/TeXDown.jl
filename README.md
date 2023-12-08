# TexDown.jl

TeXDown converts simple Markdown files into LaTeX, with optional preambles designed for my common uses. This package solves two niche problems I have:

1. I would like to compile Markdown into LaTeX that is very similar to what I myself would have written. The common advice for converting Markdown to LaTeX is to use [Pandoc](https://pandoc.org), however, the LaTeX produced by this process is borderline unintelligible (even if it does compile to a reasonable looking PDF). This makes it difficult to make edits, or incorporate into a separate LaTeX file, or share with collaborators.
2. I would like to be able to add a preamble, and ideally go directly from Markdown to PDF without having to muck around with LaTeX at all. This is useful for e.g. taking a simple todo list in Markdown and printing to PDF.

TeXDown is really just a fairly lightweight wrapper for [CommonMark.jl](https://github.com/MichaelHatherly/CommonMark.jl). The main additions are:

* CommonMark still produces a handful of odd LaTeX artifacts that TeXDown removes (e.g. `\par` at the end of each paragraph).
* Adds preambles for three of my common use cases: writing a research note, writing a todo list, and writing a recipe. 
* Apple Shortcuts scripts to go directly from Markdown to PDF with a single keyboard shortcut.

See the [examples](examples/) folder for more examples and technical descriptions of the capabilities.

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

### Optional: add shortcut
You can download a simple shortcut for converting a todo list in Markdown directly to PDF [here](https://www.icloud.com/shortcuts/447956dcd2db44db861ba56869fb1631).
