"""
    fix_list_formatting(str::String)

Delete itemize and enumerate formatting added by CommonMark.jl.
"""
function fix_list_formatting(str::String)
    itemize_formatting = "\\setlength{\\itemsep}{0pt}\n\\setlength{\\parskip}{0pt}"
    enumerate_formatting = "\\def\\labelenumi{\\arabic{enumi}.}\n\\setcounter{enumi}{0}"
    str = replace(str, itemize_formatting => "")
    str = replace(str, enumerate_formatting => "")
    return str
end


"""
    fix_figure_width(str::String)

Adjust erroneous figure width formatting added by CommonMark.jl
"""
function fix_figure_width(str::String)
    return replace(str, "max width=\\linewidth" => "width=0.8\\textwidth")
end


"""
    fix_task_checkboxes(str::String)

Convert GitHub-style task checkboxes (`- [ ]` / `- [x]`) into LaTeX.

CommonMark.jl passes the markers through as literal text, which LaTeX then swallows
as `\\item`'s optional argument. Unchecked boxes become plain items (the `todo_list`
template already labels every item with `\$\\square\$`); checked boxes get a
`\$\\boxtimes\$` label instead.
"""
function fix_task_checkboxes(str::String)
    str = replace(str, r"\\item\n\[ ?\] ?" => "\\item ")
    str = replace(str, r"\\item\n\[[xX]\] ?" => "\\item[{\$\\boxtimes\$}] ")
    return str
end


"""
    fix_quotation_marks(str::String)

Replace straight quotation marks with LaTeX-style quotation marks.

Quotes inside code (`\\texttt`, `lstlisting`, `verbatim`) and math environments are
left untouched, and quotes are only paired within a single line, so an unpaired
quote in one list item cannot swallow the items that follow it.
"""
function fix_quotation_marks(str::String)
    # regions where straight quotes must be preserved verbatim
    protected_patterns = [
        r"\\begin{lstlisting}.*?\\end{lstlisting}"s,
        r"\\begin{verbatim}.*?\\end{verbatim}"s,
        r"\\begin{equation\*?}.*?\\end{equation\*?}"s,
        r"\\texttt(\{(?:[^{}]++|(?1))*+\})",  # recursive: handles braces inside code
        r"\\\(.*?\\\)",
    ]

    protected = String[]
    for pattern in protected_patterns
        str = replace(str, pattern => m -> begin
            push!(protected, m)
            "\0TXD$(length(protected))\0"
        end)
    end

    str = replace(str, r"\"([^\"\n]*)\"" => s"``\1''")

    for (i, region) in enumerate(protected)
        str = replace(str, "\0TXD$i\0" => region)
    end
    return str
end
