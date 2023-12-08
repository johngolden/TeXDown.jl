"""
    extract_title_subtitle(tex_string::String)

Parse a TeX string that may start with a title and subtitle in the format 
"\\section{Title: Subtitle}", followed by the rest of the TeX content. 

Returns a tuple (`title`, `subtitle`, `main_text`) containing:
  - `title`: Extracted title (if present), otherwise an empty string.
  - `subtitle`: Extracted subtitle (if present), otherwise an empty string.
  - `rest_of_md`: The rest of the TeX content, excluding the first line if it contains 
     the title and subtitle.

# Errors
- Throws a warning if more than one "\\section" is found in the TeX string.

# Notes
- If the first line doesn't contain a title (i.e., doesn't start with '\\section'), the 
  entire string is treated as the main TeX content.
"""
function extract_title_subtitle(tex_string::String)
    # Split the TeX string into lines
    lines = split(tex_string, "\n")

    # Check for multiple H1 headers
    h1_count = count(l -> startswith(l, "\\section"), lines)
    if h1_count > 1
        @warn("Markdown file contains more than one H1 header.")
    end

    # Initialize title, subtitle, and the rest of the markdown string
    title = ""
    subtitle = ""
    main_text = tex_string

    # Check if the first line contains a title and subtitle
    if !isempty(lines) && startswith(lines[1], "\\section")
        # Convert the first line to a String and then split
        first_line = replace(String(lines[1]), r"\\section{(.+?)}"=>s"\1")
        parts = split(first_line, ":", limit=2)

        title = parts[1]

        if length(parts) > 1
            # Extract the subtitle
            subtitle = strip(parts[2])
        end

        # The rest of the TeX string is everything except the first line
        main_text = join(lines[2:end], "\n")
    else
        @warn("Markdown file does not start with an H1 header.")
    end

    return (title, subtitle, main_text)
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
    title, subtitle, main_text = extract_title_subtitle(str)
    
    if subtitle != ""
        @warn("Research note template does not support subtitles, discarding")
    end

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
                \\usepackage{listings}

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
    
    # add lines to equations
    main_text = replace(main_text, "\\begin{equation*}" => "\\begin{equation}")
    main_text = replace(main_text, "\\end{equation*}" => "\\end{equation}")
    
    return preamble * main_text * "\n\\end{document}"
end


"""
    todo_list(str::String)

Add a LaTeX preamble to `str` appropriate for a simple todo list.

Notes:
* assumes only a single H1 header in the input Markdown file of the format 
  "# Title: subtitle"
"""
function todo_list(str::String)
    title, subtitle, main_text = extract_title_subtitle(str)

    preamble = """
    \\documentclass[11pt,letterpaper]{article}

    \\usepackage{fancyhdr}
    \\usepackage[hmargin=2cm,top=2.5cm,bottom=3cm]{geometry}
    \\usepackage{amssymb}
    \\usepackage{setspace}
    \\usepackage{multicol}
    
    \\usepackage{enumitem}
    \\setlist[itemize]{topsep=0pt, partopsep=0pt, parsep=0pt, label=\$\\square\$}
    
    \\renewcommand{\\familydefault}{\\sfdefault}
    \\renewcommand{\\headrulewidth}{0pt}
    
    \\pagestyle{fancy}
    \\setlength\\parindent{0in}
    \\setlength\\parskip{10pt}
    \\setlength\\headheight{50pt}
    \\setstretch{.8}
    \\setlength{\\columnsep}{3em}
    \\pagenumbering{gobble}
    \\lhead{{\\Huge \\textbf{$title}} \\quad{\\LARGE $subtitle}}
    
    \\begin{document}
    
    \\begin{multicols*}{2}
    """

    # remove numbers from (sub)sections
    main_text = replace(main_text, "section{"=>"section*{")

    # turn \hbars into new columns
    main_text = replace(main_text, "\\par\\bigskip\\noindent\\hrulefill\\par\\bigskip"
                                    =>"\n\\vfill\\null\\columnbreak")


    return preamble * main_text * "\n\\end{multicols*}\n\\end{document}"
end

"""
    recipe(str::String)

Add a LaTeX preamble to `str` appropriate for a recipe.

Notes:
* prints to a half-sheet (8.5" x 5.5")
* converts x/y to \\nicefrac{x}{y}
* assumes only a single H1 header in the input Markdown file of the format 
  "# Title: subtitle"
"""
function recipe(str::String)
    title, subtitle, main_text = extract_title_subtitle(str)

    preamble = """
    \\documentclass{article}
    \\usepackage[paperwidth=8.5in,paperheight=5.5in,hmargin=2cm,top=1cm,bottom=3cm]{geometry}

    \\usepackage{fancyhdr}
    \\usepackage{amssymb}
    \\usepackage{setspace}
    \\usepackage{multicol}
    \\usepackage{units}

    \\usepackage{enumitem}
    \\setlist[itemize]{topsep=0pt, partopsep=0pt, itemsep=4pt, parsep=0pt}

    \\renewcommand{\\familydefault}{\\sfdefault}
    \\setlength\\parindent{0in}
    \\setlength\\parskip{10pt}
    \\setlength{\\columnsep}{3em}

    \\fancypagestyle{fancy}{
    \\renewcommand{\\headrulewidth}{0pt}
    \\setlength\\headheight{50pt}
    \\lhead{{\\Huge \\textbf{$title}} \\quad{\\LARGE $subtitle}}
    }
    \\pagestyle{plain}
    \\pagenumbering{gobble}

    \\begin{document}
    \\thispagestyle{fancy}
    \\begin{multicols*}{2}
    """

    # remove numbers from (sub)sections
    main_text = replace(main_text, "section{"=>"section*{")

    # replace "x/y" with "\nicefrac{x}{y}" when x and y are both numbers
    main_text = replace(main_text, r"(\d+)/(\d+)" => s"\\nicefrac{\1}{\2}")

    # turn \hbars into new columns
    main_text = replace(main_text, "\\par\\bigskip\\noindent\\hrulefill\\par\\bigskip"
    =>"\n\\vfill\\null\\columnbreak")

    return preamble * main_text * "\n\\end{multicols*}\n\\end{document}"
end