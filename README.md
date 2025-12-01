# TeXDown.jl

TeXDown converts Markdown files into nicely formatted PDFs via LaTeX. It solves two problems:

1. **Human-readable LaTeX output.** Unlike Pandoc, TeXDown produces LaTeX that looks like something you'd write yourself—easy to edit or share.
2. **Direct Markdown-to-PDF.** Go from a todo list in Markdown to a printable PDF without touching LaTeX.

TeXDown is a lightweight wrapper around [CommonMark.jl](https://github.com/MichaelHatherly/CommonMark.jl) that cleans up LaTeX artifacts and adds preamble templates for common use cases: research notes, todo lists, and recipes.

See the [examples](examples/) folder for sample output.

## Installation

### 1. Install Julia
Download from [julialang.org](https://julialang.org/downloads/).

### 2. Install TeXDown
```julia
using Pkg
Pkg.add(url="https://github.com/johngolden/TeXDown.jl")
```

### 3. Install LaTeX
Via Homebrew:
```zsh
brew install --cask mactex-no-gui
```

### 4. Add CLI to PATH (optional)
```zsh
ln -s /path/to/TeXDown.jl/bin/texdown /usr/local/bin/texdown
```

## Usage

### Command Line

```zsh
texdown "My Todo.md"                    # PDF with todo_list template (default)
texdown pdf "Notes.md" research_note    # PDF with specific template
texdown tex "Notes.md"                  # LaTeX only
```

Templates: `todo_list` (default), `research_note`, `recipe`

### Apple Shortcuts

Right-click a Markdown file → Quick Actions → select a TeXDown shortcut. First-time use requires granting permissions.

**Tip:** Assign a keyboard shortcut (e.g., `Option-Shift-P`) via Shortcuts app → open shortcut → click "ℹ︎" → set "Run with:".

**Markdown to PDF:**
[Todo list](https://www.icloud.com/shortcuts/447956dcd2db44db861ba56869fb1631) ·
[Research note](https://www.icloud.com/shortcuts/45c416490ffd4f0eb9b099ae7919bd19) ·
[Recipe](https://www.icloud.com/shortcuts/24b1beeefbd84abbb282bb011a3db4a1)

**Markdown to LaTeX:**
[Todo list](https://www.icloud.com/shortcuts/4e39d211b3e5450898c92e9d96f2890d) ·
[Research note](https://www.icloud.com/shortcuts/d94943b28ee04d4daee6c2d6ca10088d) ·
[Recipe](https://www.icloud.com/shortcuts/902037aa4bcf4e64aeae77fa2816222d) ·
[No Preamble](https://www.icloud.com/shortcuts/967334bb0872405db3c95d7124d03bce)

**Recipe utilities:**
[Combine recipe PDFs](https://www.icloud.com/shortcuts/eca3563e1407489eb119ddf4c6faa13b) — combines 8.5"×5.5" recipe PDFs for printing on letter paper.

### VSCode

Add to `.vscode/tasks.json`:
```json
{
  "version": "2.0.0",
  "tasks": [{
    "label": "TeXDown: Generate PDF",
    "type": "shell",
    "command": "texdown",
    "args": ["pdf", "${file}"],
    "group": "build",
    "problemMatcher": []
  }]
}
```

Add keybinding in `~/Library/Application Support/Code/User/keybindings.json`:
```json
{
  "key": "cmd+shift+t",
  "command": "workbench.action.tasks.runTask",
  "args": "TeXDown: Generate PDF",
  "when": "editorLangId == markdown"
}
```

### Obsidian

Install [Shell commands](https://github.com/Taitava/obsidian-shellcommands) plugin, then add:
```
texdown pdf "{{file_path:absolute}}"
```
Assign a hotkey in plugin settings.

### Julia API

```julia
make_tex(md_content)              # Markdown string or file → LaTeX (no preamble)
make_tex(md_content, template)    # With preamble template
make_pdf(md_file, template)       # Compile to PDF, clean up aux files, open
```
