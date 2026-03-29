# LaTeX → PDF via Docker (outputs to out/)
set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

image := "latex-templates-local"
root := justfile_directory()

# Build the LaTeX toolchain image (cached after the first run)
docker-build:
    docker build -f "{{root}}/docker/Dockerfile" -t {{image}} "{{root}}"

# Compile a .tex file to PDF under out/ (e.g. just pdf examples/cv-example.tex)
pdf tex: docker-build
    docker run --rm \
      -v "{{root}}:/work" \
      -w /work \
      -e TEXINPUTS=./templates//: \
      {{image}} \
      latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir=out "{{tex}}"
