# A Research Note

In this note we have some simple Markdown examples and show their conversion to PDF via LaTeX.

## Handling sections
Use H1 (#) for the title, and then H2 (##) for sections.
H2 headers start at the `subsection` level, and are not numbered.
H3 headers (###) and lower just get turned into `paragraph`s.

### A subsection
Here's a subsection.

#### A subsubsection
... is now a `paragraph` environment.

## Equations
Here's an inline equation: $E = mc^2$.

Here's a regular equation:
$$
-\frac{\hbar^2}{2m}\nabla^2\psi(r,t) + V(r)\psi(r,t) = i\hbar \frac{\partial}{\partial t}\psi(r,t)
$$

For multi-line equations, you can use the `align` environment (or `gather`, or `eqnarray`, etc...) like this:
```{=latex}
\begin{align}
a & = b + c \\
x & = y - z
\end{align}
```
Unfortunately the raw LaTeX doesn't render in most Markdown previewers, e.g. VSCode. 
However, for reasons that are mysterious to me, the VSCode Markdown previewer does allow for newlines via `\\` in equation mode. So if you want to do multiline like that to start, and then switch to the `align` environment manually before compiling to LaTeX/pdf, go for it. 

Note that you don't need to add a blank line before a full-line equation in the Markdown file, e.g. you can write
```
some text
$$
1+1=2
$$
```
instead of
```
some text

$$
1+1=2
$$
```

And here's a matrix:
$$
A = 
\begin{pmatrix}
    2 & -1 &  0 & 0 \\
    -1 &  2 & -1 & 0 \\
    0 & -1 &  2 & -1 \\
    0 &  0 & -1 & 2 \\
\end{pmatrix},~~~
b = 
\begin{pmatrix}
    1 \\ 1 \\ 0 \\ 0
\end{pmatrix}.
$$

## Inline code
Here's some `inline code`.

## Lists
Here's a simple list:
* x
* y
* z

Here's an enumerated list:
1. x
2. y
3. z

Here's an enumerated list with an equation:
1. x
2. y
3. an equation:
$$
a+b
$$
4. z

## Tables
Here's a simple table. Something is a little off with the rendering, not sure why...

| Syntax      | Description |
| ----------- | ----------- |
| Header      | Title       |
| Paragraph   | Text        |


## Figures
Here's a figure with a caption:

![](fig1.pdf)
_A caption_

