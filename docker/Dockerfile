# TeX Live with packages required by templates/ (cv-template and future .sty files)
FROM debian:bookworm-slim

# Debian TeX Live splits Latin Modern; the standalone `lmodern` package ships lmodern.sty
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    lmodern \
    latexmk \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-font-utils \
    texlive-plain-generic \
  && rm -rf /var/lib/apt/lists/*

# Search path for \usepackage{cv-template} when project root is mounted at /work
ENV TEXINPUTS=./templates//:

WORKDIR /work
