"""
    add_captions_to_figures(str::String)

Take italic text directly under figures and make it the caption.

# Example

\\caption{}
\\end{figure}
\\textit{A caption for this figure}

becomes

\\caption{A caption for this figure}
\\end{figure}
"""
function add_captions_to_figures(str::String)
    return replace(str, r"\\caption{}\n\\end{figure}\n\\textit{(.*)}\n" => s"\\caption{\1}\n\\end{figure}\n")
end