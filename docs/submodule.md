# Using this repository as a git submodule

Public repositories can hold **templates**, **Docker**, and **examples**; private repositories can add this project as a **submodule** and keep real CV or document sources out of the public tree.

## Quick bootstrap (AI agent or copy-paste)

If you paste a link to this repo into an AI coding agent in an **empty folder**, it should follow **[AGENTS.md](../AGENTS.md)**:

1. `git init` (if you want git + submodule).
2. `git submodule add <URL> latex-templates` and `git submodule update --init --recursive`.
3. Add `.gitignore` with `/out/`.
4. Create `main.tex` at the project root (single document) or, for multiple documents, `docs/<name>/<unique>.tex` (e.g. `docs/cv/cv.tex`) — use **distinct basenames** so `latexmk -outdir=out` does not overwrite one `out/main.pdf` with another. Copy from the example path in [`templates/manifest.yml`](../templates/manifest.yml) for your template (`cv` today).
5. Build with Docker using `TEXINPUTS=./latex-templates/templates//:` (see below).

**Suggested layouts**

- **Single document**: `main.tex` + `latex-templates/` submodule + `out/`.
- **Multiple documents** (recommended for several CVs/letters in one private repo): one `latex-templates/` submodule at the root, multiple `docs/<topic>/main.tex` files.

## Add the submodule

From the root of your private repository:

```bash
git submodule add <URL-of-this-repo> latex-templates
git submodule update --init --recursive
```

Use any directory name you prefer instead of `latex-templates`; the snippets below assume `latex-templates/`.

## Layout

- `latex-templates/` — submodule (this repo)
- `cv.tex` (or `src/cv.tex`) — your document using `\usepackage{cv-template}`
- `out/` — PDF output (add `out/` to `.gitignore` in the private repo)

## `TEXINPUTS`

LaTeX must find `cv-template.sty` inside the submodule’s `templates/` directory, not only the private repo root. Set:

```text
TEXINPUTS=./latex-templates/templates//:
```

The trailing `:` keeps the default TeX Live search paths.

## Build the Docker image from the submodule

```bash
docker build -f latex-templates/docker/Dockerfile -t latex-templates-local latex-templates
```

## Compile with Docker (private repo root mounted at `/work`)

```bash
docker run --rm \
  -v "$PWD:/work" \
  -w /work \
  -e TEXINPUTS=./latex-templates/templates//: \
  latex-templates-local \
  latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir=out cv.tex
```

The PDF is written to `out/cv.pdf` when the main file is `cv.tex`.

## Optional `just` wrapper in the private repo

Point `root` at your private repo root and pass the same `TEXINPUTS` and `latex-templates/docker/Dockerfile` path when building the image.
