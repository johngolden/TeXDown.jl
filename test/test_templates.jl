using Test
using TeXDown

# test_helpers.jl is included from runtests.jl

@testset "templates.jl" begin

    @testset "extract_title_subtitle" begin
        @testset "basic behavior" begin
            # Title with subtitle
            input = "\\section{Title: Subtitle}\nrest"
            title, subtitle, main = TeXDown.extract_title_subtitle(input)
            @test title == "Title"
            @test subtitle == "Subtitle"
            @test main == "rest"

            # Title without subtitle
            input = "\\section{Just Title}\nrest"
            title, subtitle, main = TeXDown.extract_title_subtitle(input)
            @test title == "Just Title"
            @test subtitle == ""
            @test main == "rest"
        end

        @testset "edge cases" begin
            # No H1 header - warns and returns full content
            input = "\\subsection{Not H1}\nrest"
            title, subtitle, main = @test_logs (:warn,) TeXDown.extract_title_subtitle(input)
            @test title == ""
            @test subtitle == ""
            @test main == input

            # Multiple H1 headers - warns
            input = "\\section{First}\n\\section{Second}"
            title, subtitle, main = @test_logs (:warn,) TeXDown.extract_title_subtitle(input)
            @test title == "First"

            # Empty string - warns
            title, subtitle, main = @test_logs (:warn,) TeXDown.extract_title_subtitle("")
            @test title == ""
            @test subtitle == ""
            @test main == ""

            # Title with multiple colons
            input = "\\section{Title: Sub: More}\nrest"
            title, subtitle, main = TeXDown.extract_title_subtitle(input)
            @test title == "Title"
            @test subtitle == "Sub: More"

            # Whitespace around subtitle
            input = "\\section{Title:   Spaced   }\nrest"
            title, subtitle, main = TeXDown.extract_title_subtitle(input)
            @test subtitle == "Spaced"
        end
    end

    @testset "research_note" begin
        @testset "basic behavior" begin
            # Creates proper LaTeX document
            input = "\\section{My Note}\nContent here"
            result = TeXDown.research_note(input)

            @test contains(result, "\\documentclass")
            @test contains(result, "\\begin{document}")
            @test contains(result, "\\end{document}")
            @test contains(result, "\\rhead{\\textsc{My Note}}")
            @test contains(result, "Content here")
        end

        @testset "edge cases" begin
            # Subtitle generates warning
            input = "\\section{Title: Subtitle}\nContent"
            result = @test_logs (:warn, r"subtitle") TeXDown.research_note(input)
            @test contains(result, "\\rhead{\\textsc{Title}}")

            # Converts equation* to equation
            input = "\\section{Title}\n\\begin{equation*}\nx=1\n\\end{equation*}"
            result = TeXDown.research_note(input)
            @test contains(result, "\\begin{equation}")
            @test contains(result, "\\end{equation}")
            @test !contains(result, "equation*")
        end
    end

    @testset "todo_list" begin
        @testset "basic behavior" begin
            input = "\\section{Todo: Today}\n\\subsection{Tasks}\n\\begin{itemize}\n\\item Do stuff\n\\end{itemize}"
            result = TeXDown.todo_list(input)

            @test contains(result, "\\documentclass")
            @test contains(result, "\\begin{multicols*}{2}")
            @test contains(result, "\\end{multicols*}")
            @test contains(result, "\\Huge \\textbf{Todo}")
            @test contains(result, "\\LARGE Today")
            @test contains(result, "\$\\square\$")  # Checkbox
        end

        @testset "edge cases" begin
            # Removes section numbering
            input = "\\section{Title}\n\\subsection{Section}"
            result = TeXDown.todo_list(input)
            @test contains(result, "\\subsection*{Section}")

            # Converts hrule to column break
            input = "\\section{Title}\n\\par\\bigskip\\noindent\\hrulefill\\par\\bigskip"
            result = TeXDown.todo_list(input)
            @test contains(result, "\\vfill\\null\\columnbreak")
        end
    end

    @testset "recipe" begin
        @testset "basic behavior" begin
            input = "\\section{Waffles}\n\\begin{itemize}\n\\item 1/2 cup flour\n\\end{itemize}"
            result = TeXDown.recipe(input)

            @test contains(result, "\\documentclass")
            @test contains(result, "paperheight=5.5in")  # Half-sheet
            @test contains(result, "\\begin{multicols*}{2}")
        end

        @testset "edge cases" begin
            # Converts fractions to nicefrac
            input = "\\section{Recipe}\n1/2 cup and 3/4 teaspoon"
            result = TeXDown.recipe(input)
            @test contains(result, "\\nicefrac{1}{2}")
            @test contains(result, "\\nicefrac{3}{4}")

            # Unicode fraction slash also works
            input = "\\section{Recipe}\n1\u20444 cup"  # Unicode fraction slash
            result = TeXDown.recipe(input)
            @test contains(result, "\\nicefrac{1}{4}")

            # Removes section numbering
            input = "\\section{Title}\n\\subsection{Ingredients}"
            result = TeXDown.recipe(input)
            @test contains(result, "\\subsection*{Ingredients}")

            # Converts hrule to column break
            input = "\\section{Title}\n\\par\\bigskip\\noindent\\hrulefill\\par\\bigskip"
            result = TeXDown.recipe(input)
            @test contains(result, "\\vfill\\null\\columnbreak")
        end
    end
end
