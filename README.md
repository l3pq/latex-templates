# LaTeX templates

Shared LaTeX style files and tooling to compile documents to PDF.

## Layout

| Path | Purpose |
|------|---------|
| `templates/` | `.sty` packages (e.g. `cv-template`) |
| `examples/` | Example `.tex` sources per template |
| `out/` | Build output (PDF); ignored by git |
| `docker/` | Dockerfile for a reproducible TeX Live environment |

## Requirements

- [Docker](https://docs.docker.com/get-docker/)
- [just](https://github.com/casey/just) (command runner)

## Build a PDF

From this repository root:

```bash
just pdf examples/cv-example.tex
```

The PDF is written to `out/cv-example.pdf`.

## Git submodule (private documents)

To consume these templates from a private repository (real CV sources, etc.), see [docs/submodule.md](docs/submodule.md).
