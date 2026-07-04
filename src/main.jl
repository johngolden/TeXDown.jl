"""
    make_tex(md_content)

Turn `md_content` -- either a Markdown file or string -- into LaTeX without a preamble.
"""
function make_tex(md_content; save=false)
    if endswith(md_content, ".md")
        if !isfile(md_content)
            error("File not found: $md_content")
        end
        md_str = open(md_content, "r") do contents
            read(contents, String)
        end
    else
        md_str = md_content
    end

    # format the markdown string before parsing to latex
    # (count blank lines first, before equation formatting adds newlines of its own)
    md_str = preserve_blank_lines(md_str)
    md_str = add_newlines_to_equations(md_str)

    # convert to latex
    tex_str = md_to_tex(md_str)

    # fix CommonMark.jl bugs/shortcomings
    tex_str = fix_list_formatting(tex_str)
    tex_str = fix_task_checkboxes(tex_str)
    tex_str = fix_figure_width(tex_str)
    tex_str = fix_quotation_marks(tex_str)

    # add extensions
    tex_str = add_captions_to_figures(tex_str)

    # make the latex file look nice
    tex_str = replace_par_with_newlines(tex_str)
    tex_str = remove_environment_padding(tex_str)
    tex_str = remove_list_newlines(tex_str)
    tex_str = add_newlines_before_subsections(tex_str)
    tex_str = remove_double_empty_lines(tex_str)
    tex_str = add_indents(tex_str)

    if save
        save_tex(md_content, tex_str)
    else
        return tex_str
    end
end

"""
    make_tex(md_content, template)

Convert the contents of `md_content` into LaTeX with `template`.
"""
function make_tex(md_content, template; save=true)
    tex_str = make_tex(md_content)
    tex_str = template(tex_str)

    if save
        save_tex(md_content, tex_str)
    else
        return tex_str
    end
end

"""
    save_tex(md_content, tex_str)

Save the TeX string to a file.

Only works if `md_content` is Markdown file.
"""
function save_tex(md_content, tex_str)
    if isfile(md_content)
        tex_filename = replace(md_content, ".md" => ".tex")

        open(tex_filename, "w") do file
            write(file, tex_str)
        end
    else
        return tex_str
    end
end

"""
    make_pdf(md_file, template; open=true)

Convert the contents of `md_file` to a LaTeX file according to `template` and compile to
pdf, deleting the auxiliary files and opening the pdf after successful compilation.
Pass `open=false` to skip opening the pdf (e.g. for unattended/scripted use).

The pdf is stored in the same location as `md_file`. `pdflatex` runs quietly; on
failure the relevant error lines from the log are printed and the `.tex`/`.log` files
are kept for inspection.
"""
function make_pdf(md_file, template; open::Bool=true)
    # Validate input
    if !isfile(md_file)
        error("File not found: $md_file")
    end

    make_tex(md_file, template)

    # Get absolute path and split into directory and filename
    abs_path = abspath(md_file)
    dir = dirname(abs_path)
    filename, _ = splitext(basename(abs_path))
    tex_file = filename * ".tex"
    pdf_file = filename * ".pdf"
    log_file = filename * ".log"

    # Run pdflatex from the file's directory to handle paths with spaces
    cd(dir) do
        run_pdflatex(tex_file, log_file)

        # a second pass is only needed when LaTeX asks for one (cross-references)
        if isfile(log_file) && occursin("Rerun", read(log_file, String))
            run_pdflatex(tex_file, log_file)
        end

        if !isfile(pdf_file) || filesize(pdf_file) == 0
            rm(pdf_file, force=true)
            error("pdflatex produced no pages (empty document?); kept $tex_file for inspection.")
        end

        delete_aux_files(filename)
        open && run(`open $pdf_file`)
    end
end

"""
    run_pdflatex(tex_file, log_file)

Run `pdflatex` quietly. On failure, print just the error lines from the log and throw,
leaving the `.tex` and `.log` files in place for inspection.
"""
function run_pdflatex(tex_file, log_file)
    cmd = `pdflatex -interaction=nonstopmode -file-line-error $tex_file`
    try
        run(pipeline(cmd, stdout=devnull, stderr=devnull))
    catch
        errors = latex_error_lines(log_file)
        if !isempty(errors)
            @error "pdflatex failed:\n" * join(errors, "\n")
        end
        error("pdflatex failed for $tex_file; kept $tex_file and $log_file for inspection.")
    end
end

"""
    latex_error_lines(log_file)

Extract the error lines (`file:line: message`, `! message`, and `l.<n>` context)
from a `pdflatex` log file.
"""
function latex_error_lines(log_file)
    isfile(log_file) || return String[]
    lines = readlines(log_file)
    return [l for l in lines if startswith(l, "!") ||
                                occursin(r"^\S*\.tex:\d+:", l) ||
                                occursin(r"^l\.\d+", l)]
end

"""
    delete_aux_files(filename)

Delete auxiliary `pdflatex` files.
"""
function delete_aux_files(filename)
    for ext in ["log", "aux", "out", "tex"]
        filepath = "$filename.$ext"
        if isfile(filepath)
            rm(filepath)
        end
    end
end
