---
name: latex-submodule-bootstrap
description: >-
  Bootstraps a new LaTeX consumer project using this templates repository as a
  git submodule (Docker + latexmk, TEXINPUTS for templates/). Use when the user
  pastes a link to the public latex-templates repo, asks to start a new CV or
  document project from those templates, or wants submodule setup for private
  sources with shared .sty packages.
---

# LaTeX submodule bootstrap

## When to apply

- User provides **URL** to `latex-templates` (or clone of it) and wants a **new project** ready to build.
- User mentions **submodule**, **private repo + public templates**, or **bootstrap from template link**.

## Primary reference

Read and follow **[AGENTS.md](../../../AGENTS.md)** at the root of the templates repository. It defines inputs, modes, paths, and exact Docker commands.

## Quick procedure

1. **Normalize** the repo URL (HTTPS or SSH as the user prefers).
2. **Choose mode**: `single-document` (default) vs `multi-document` — ask only if unclear.
3. **Template id**: read [templates/manifest.yml](../../../templates/manifest.yml); default to first template with `available: true` (currently `cv`).
4. **`git init`** in the consumer folder if needed and the user wants git/submodules.
5. **`git submodule add <URL> latex-templates`** then `git submodule update --init --recursive`.
6. Add **`.gitignore`** with `/out/`.
7. Create **`main.tex`** at the project root (single-document), or **`docs/<name>/<unique>.tex`** for multi-document (e.g. `docs/cv/cv.tex` — avoid multiple `main.tex` or PDFs will collide in `out/`). Adapt from the manifest’s `example_relative_path` inside `latex-templates/`.
8. Add a short **consumer `README.md`** with:
   - `docker build -f latex-templates/docker/Dockerfile -t latex-templates-local latex-templates`
   - `docker run ... -e TEXINPUTS=./latex-templates/templates//: ... latexmk ... -outdir=out <path-to-main.tex>`
9. **Verify** paths: `TEXINPUTS` must end with `:`; submodule path must match all commands.

## Do not

- Do not set `TEXINPUTS=./templates//:` in the consumer project (that is only valid inside the templates repo root).
- Do not commit `out/` PDFs in the consumer repo.

## Multi-template future

When adding a new template, update `templates/manifest.yml` with `available: true` and real `sty_relative_path` / `example_relative_path`. Prefer copying the example into the user’s `main.tex` rather than compiling the example path inside the submodule as the user’s only source file.
