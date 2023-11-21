"""
    find_title(str::String)

Searches the given Markdown text for the first H1 header and returns it.
If no H1 header is found, returns an empty string.
"""
function find_title(str::String)
    h1_header_regex = r"^#\s*(.*)" # regex to match an H1 header
    match_result = match(h1_header_regex, markdown_text)
    return isnothing(match_result) ? "" : match_result.captures[1]
end

"""
    research_note(str::String)

Add a LaTeX preamble to `str` appropriate for a simple research note.

Notes:
* includes the name "John Golden" by default
* assumes only a single H1 header in the input Markdown file, and converts that to the title
  on each page in the research note
"""
function research_note(str::String)
    title = find_title(str)
    preamble = """
                \\documentclass[11pt,letterpaper]{article}

                \\usepackage{fancyhdr}
                \\usepackage[hmargin=2cm,vmargin=2.5cm]{geometry}
                \\usepackage{graphicx}
                \\usepackage{amsmath}
                \\usepackage{amsfonts}
                \\usepackage{amssymb}
                \\usepackage{hyperref}
                \\usepackage{braket}
                \\usepackage{float}
                \\usepackage{longtable}

                \\pagestyle{fancy}
                \\setlength\\parindent{0in}
                \\setlength\\parskip{0.1in}
                \\setlength\\headheight{15pt}

                \\lhead{\\textsc{John Golden}}
                \\rhead{\\textsc{$(title)}}
                \\rfoot{\\textsc{\\thepage}}
                \\cfoot{}
                \\lfoot{\\textit{Updated: \\today}}

                \\setcounter{secnumdepth}{0}

                \\begin{document}

                """

    # strip the H1 header 
    main_text = replace(str, r"\\section\{[^}]*\}\n" => "")
    return preamble * main_text * "\n\\end{document}"
end