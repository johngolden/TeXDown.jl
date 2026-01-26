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
    end
end
