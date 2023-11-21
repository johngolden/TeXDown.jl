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
    fix_quotation_marks(str::String)

Replace straight quotation marks with LaTeX-style quotation marks.
"""
function fix_quotation_marks(str::String)
    return replace(str, r"\"([^\"]*)\"" => s"``\1''")
end
