# Agent bootstrap contract — LaTeX projects from this templates repo

This file defines how an AI agent should scaffold a **new consumer project** when the user provides a **public URL** to this repository (e.g. `https://github.com/l3pq/latex-templates` or SSH `git@github.com:l3pq/latex-templates.git`).

## Inputs (collect from the user)

1. **Templates repo URL** — normalize to a form `git` accepts (`git@...` or `https://...`).
2. **Template id** — read from [`templates/manifest.yml`](templates/manifest.yml). If the user does not specify, default to `cv` (first `available: true` entry).
3. **Project mode** — infer or ask only if ambiguous:
   - **`single-document`**: one main `.tex` at repo root (or a single subfolder the user names).
   - **`multi-document`**: several documents under `docs/<name>/` sharing one submodule `latex-templates/`.

## Preconditions

- **Git**: submodule workflow requires a git repository. If the directory is empty and not a repo, run `git init` unless the user explicitly asked for a non-git folder (then document that they cannot use submodules without git).
- **Docker**: builds use the image built from `latex-templates/docker/Dockerfile` inside the submodule.

## Canonical paths (do not invent different names unless the user insists)

| Path | Role |
|------|------|
| `latex-templates/` | Git submodule pointing at this templates repository |
| `out/` | PDF output (must be in consumer `.gitignore`) |
| `main.tex` | Default entry file for **single-document** at project root |
| `docs/<doc>/<unique>.tex` | Entry file for each document in **multi-document** mode — use a **unique basename** (e.g. `cv.tex`, `letter.tex`), not multiple `main.tex`, see below |

## Steps (execute in order)

### 1. Resolve template metadata

- Open `templates/manifest.yml` **from the templates repo** (after clone/submodule add, or fetch raw from GitHub if bootstrapping before submodule exists).
- Pick the template by `id`. Skip entries with `available: false` unless the user explicitly wants a stub.
- Note: `sty_relative_path`, `example_relative_path`, `suggested_entry_filename`.

### 2. Add submodule

From the **consumer project root**:

```bash
git submodule add <TEMPLATES_REPO_URL> latex-templates
git submodule update --init --recursive
```

Use URL the user provided (HTTPS or SSH). Submodule path **`latex-templates`** is the default; change only if the user requests another name and then adjust all `TEXINPUTS` and Docker `-f` paths below.

### 3. Consumer `.gitignore`

Ensure at least:

```gitignore
/out/
```

### 4. Scaffold LaTeX sources

**single-document**

- Create `main.tex` at project root by adapting the content of `latex-templates/<example_relative_path>` from the chosen manifest entry (trim example-only text; keep `\usepackage{...}` matching the package name in the manifest).
- Alternatively symlink is **not** recommended; copy so the user can edit freely.

**multi-document**

- Create `docs/<template-id-or-user-label>/<unique>.tex` (one folder per document). **Use a unique `.tex` basename per document** (e.g. `docs/cv/cv.tex`, `docs/letter/letter.tex`). With `latexmk -outdir=out`, the PDF is `out/<basename>.pdf` (e.g. `out/cv.pdf`); several files named `main.tex` in different folders would all write `out/main.pdf` and overwrite each other.
- First time only: add submodule once at root. Additional documents reuse the same `latex-templates/`.

### 5. Build commands (document in consumer `README.md`)

Always set:

```text
TEXINPUTS=./latex-templates/templates//:
```

**Build image** (from consumer root):

```bash
docker build -f latex-templates/docker/Dockerfile -t latex-templates-local latex-templates
```

**Compile** — single-document (`main.tex` at root):

```bash
docker run --rm \
  -v "$PWD:/work" \
  -w /work \
  -e TEXINPUTS=./latex-templates/templates//: \
  latex-templates-local \
  latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir=out main.tex
```

**Compile** — multi-document (example: `docs/cv/cv.tex` → `out/cv.pdf`):

```bash
docker run --rm \
  -v "$PWD:/work" \
  -w /work \
  -e TEXINPUTS=./latex-templates/templates//: \
  latex-templates-local \
  latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir=out docs/cv/cv.tex
```

On Linux, add `--user "$(id -u):$(id -g)"` to the `docker run` line so files in `out/` are owned by your user (otherwise they may be `root`).

With this `latexmk` invocation, the PDF is **`out/<basename>.pdf`** (basename of the `.tex` file), not a full mirror of the source path.

### 6. Optional: `just` in the consumer repo

If the user wants `just`, mirror the pattern in [`justfile`](justfile) in this repo but set `TEXINPUTS=./latex-templates/templates//:` and point `docker build` at `latex-templates/docker/Dockerfile`.

## Repository strategy (advise the user when relevant)

- **Default recommendation**: one private **documents** repository with multiple folders under `docs/` and a **single** `latex-templates` submodule — fewer clones, one toolchain image.
- **Separate repo per document** only when access control, release cycle, or history must be isolated.

## Verification checklist

- [ ] `latex-templates/templates/` exists and contains the `.sty` from the manifest.
- [ ] Consumer `README.md` includes the exact `docker build` and `docker run` lines with correct `TEXINPUTS`.
- [ ] `out/` is gitignored.
- [ ] `git submodule status` shows `latex-templates`.

## Related docs

- Human-oriented submodule guide: [`docs/submodule.md`](docs/submodule.md)
- Template index: [`templates/manifest.yml`](templates/manifest.yml)
- Agent skill (Cursor): [`.cursor/skills/latex-submodule-bootstrap/SKILL.md`](.cursor/skills/latex-submodule-bootstrap/SKILL.md)
