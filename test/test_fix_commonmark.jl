using Test
using TeXDown

@testset "fix_commonmark.jl" begin

    @testset "fix_list_formatting" begin
        @testset "basic behavior" begin
            # Removes itemize formatting
            input = "\\setlength{\\itemsep}{0pt}\n\\setlength{\\parskip}{0pt}\nrest"
            result = TeXDown.fix_list_formatting(input)
            @test !contains(result, "\\itemsep")
            @test contains(result, "rest")

            # Removes enumerate formatting
            input = "\\def\\labelenumi{\\arabic{enumi}.}\n\\setcounter{enumi}{0}\nrest"
            result = TeXDown.fix_list_formatting(input)
            @test !contains(result, "\\labelenumi")
            @test contains(result, "rest")
        end

        @testset "edge cases" begin
            # No formatting to remove - unchanged
            input = "\\begin{itemize}\n\\item x\n\\end{itemize}"
            @test TeXDown.fix_list_formatting(input) == input

            # Empty string
            @test TeXDown.fix_list_formatting("") == ""

            # Both itemize and enumerate formatting
            input = "\\setlength{\\itemsep}{0pt}\n\\setlength{\\parskip}{0pt}\n\\def\\labelenumi{\\arabic{enumi}.}\n\\setcounter{enumi}{0}"
            result = TeXDown.fix_list_formatting(input)
            @test !contains(result, "\\itemsep")
            @test !contains(result, "\\labelenumi")
        end
    end

    @testset "fix_figure_width" begin
        @testset "basic behavior" begin
            # Replaces CommonMark's figure width
            input = "\\includegraphics[max width=\\linewidth]{fig.pdf}"
            result = TeXDown.fix_figure_width(input)
            @test contains(result, "width=0.8\\textwidth")
            @test !contains(result, "max width")
        end

        @testset "edge cases" begin
            # No figure - unchanged
            input = "no figure here"
            @test TeXDown.fix_figure_width(input) == input

            # Empty string
            @test TeXDown.fix_figure_width("") == ""

            # Multiple figures
            input = "\\includegraphics[max width=\\linewidth]{a.pdf}\n\\includegraphics[max width=\\linewidth]{b.pdf}"
            result = TeXDown.fix_figure_width(input)
            @test count("width=0.8\\textwidth", result) == 2
        end
    end

    @testset "fix_task_checkboxes" begin
        @testset "basic behavior" begin
            # Unchecked boxes become plain items (template supplies the square)
            input = "\\item\n[ ] buy milk\\par"
            result = TeXDown.fix_task_checkboxes(input)
            @test result == "\\item buy milk\\par"

            # Checked boxes get a crossed-box label
            input = "\\item\n[x] call plumber\\par"
            result = TeXDown.fix_task_checkboxes(input)
            @test result == "\\item[{\$\\boxtimes\$}] call plumber\\par"

            # Uppercase X works too
            input = "\\item\n[X] done\\par"
            result = TeXDown.fix_task_checkboxes(input)
            @test contains(result, "\\boxtimes")
        end

        @testset "edge cases" begin
            # Malformed empty brackets are treated as an unchecked box
            input = "\\item\n[] thing\\par"
            @test TeXDown.fix_task_checkboxes(input) == "\\item thing\\par"

            # Plain items untouched
            input = "\\item\nplain item\\par"
            @test TeXDown.fix_task_checkboxes(input) == input

            # Brackets mid-text untouched
            input = "\\item\nsee [x] marks the spot\\par"
            @test TeXDown.fix_task_checkboxes(input) == input

            # Empty string
            @test TeXDown.fix_task_checkboxes("") == ""
        end
    end

    @testset "fix_quotation_marks" begin
        @testset "basic behavior" begin
            # Converts straight quotes to LaTeX curly quotes
            @test TeXDown.fix_quotation_marks("\"hello\"") == "``hello''"
            @test TeXDown.fix_quotation_marks("say \"hi\"") == "say ``hi''"
        end

        @testset "edge cases" begin
            # Empty quotes
            @test TeXDown.fix_quotation_marks("\"\"") == "``''"

            # Unbalanced quote - no match, unchanged
            @test TeXDown.fix_quotation_marks("unbalanced\"") == "unbalanced\""

            # Multiple quoted sections
            result = TeXDown.fix_quotation_marks("\"a\" and \"b\"")
            @test result == "``a'' and ``b''"

            # Quote with special chars
            @test TeXDown.fix_quotation_marks("\"x=1\"") == "``x=1''"

            # No quotes - unchanged
            @test TeXDown.fix_quotation_marks("no quotes") == "no quotes"

            # Empty string
            @test TeXDown.fix_quotation_marks("") == ""

            # Nested quotes (outer matched, inner as-is)
            # The regex only matches balanced pairs, so nested quotes
            # may have unexpected behavior
            result = TeXDown.fix_quotation_marks("\"outer \"inner\" outer\"")
            # The regex "([^"]*)" is greedy and won't match across quotes
            # So "outer " will be matched first
            @test contains(result, "``")
        end

        @testset "protected regions" begin
            # Quotes inside \texttt (inline code) are preserved
            input = "run \\texttt{git commit -m \"wip\"} now"
            @test TeXDown.fix_quotation_marks(input) == input

            # ... including code containing braces
            input = "set \\texttt{\\{\"key\": \"value\"\\}} in the file"
            @test TeXDown.fix_quotation_marks(input) == input

            # Quotes inside inline math are preserved
            input = "math \\(f(\"x\")\\) here"
            @test TeXDown.fix_quotation_marks(input) == input

            # Quotes inside lstlisting/verbatim/equation environments are preserved
            for env in ["lstlisting", "verbatim", "equation"]
                input = "\\begin{$env}\nprint(\"hi\")\n\\end{$env}"
                @test TeXDown.fix_quotation_marks(input) == input
            end

            # Prose around a protected region still gets fixed
            input = "say \"hi\" and run \\texttt{echo \"x\"}"
            result = TeXDown.fix_quotation_marks(input)
            @test contains(result, "``hi''")
            @test contains(result, "\\texttt{echo \"x\"}")

            # Quotes are only paired within a single line, so an unpaired
            # quote cannot swallow the lines that follow it
            input = "\\item a \"quote opens\n\\item b\n\\item c closes\" here"
            result = TeXDown.fix_quotation_marks(input)
            @test contains(result, "\\item b")
            @test !contains(result, "``")
        end
    end
end
