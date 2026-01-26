using Test
using TeXDown

# test_helpers.jl is included from runtests.jl

@testset "extensions.jl" begin

    @testset "add_captions_to_figures" begin
        @testset "basic behavior" begin
            # Moves italic text after figure into caption
            input = heredoc("""
                \\caption{}
                \\end{figure}
                \\textit{A caption for this figure}
                """)
            result = TeXDown.add_captions_to_figures(input)
            @test contains(result, "\\caption{A caption for this figure}")
            @test !contains(result, "\\textit{A caption")
        end

        @testset "edge cases" begin
            # No caption pattern - unchanged
            input = heredoc("""
                \\caption{Already has caption}
                \\end{figure}
                """)
            @test TeXDown.add_captions_to_figures(input) == input

            # Empty caption, no italic - unchanged
            input = heredoc("""
                \\caption{}
                \\end{figure}
                Regular text
                """)
            @test TeXDown.add_captions_to_figures(input) == input

            # Empty string
            @test TeXDown.add_captions_to_figures("") == ""

            # Caption with special characters
            input = heredoc("""
                \\caption{}
                \\end{figure}
                \\textit{Caption with \$math\$ and \\textbf{bold}}
                """)
            result = TeXDown.add_captions_to_figures(input)
            @test contains(result, "\\caption{Caption with \$math\$ and \\textbf{bold}}")

            # Multiple figures
            input = heredoc("""
                \\caption{}
                \\end{figure}
                \\textit{First caption}
                More text
                \\caption{}
                \\end{figure}
                \\textit{Second caption}
                """)
            result = TeXDown.add_captions_to_figures(input)
            @test contains(result, "\\caption{First caption}")
            @test contains(result, "\\caption{Second caption}")
        end
    end
end
