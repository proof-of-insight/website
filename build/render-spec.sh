#!/usr/bin/env bash
# Render a versioned Proof of Insight specification to HTML and PDF.
#
# Usage: ./build/render-spec.sh <version> [--ref <git-ref>]
# Example: ./build/render-spec.sh v0.6.2
# Example (pre-tag development): ./build/render-spec.sh v0.6.2 --ref main
#
# By default the script clones the spec repository at the tag matching
# <version>, so a versioned URL like /spec/v0.6.2/ is pinned to the
# immutable contents of the v0.6.2 tag. Pass --ref to override (useful
# before a tag has been cut).

set -euo pipefail

VERSION="${1:?missing version argument (e.g., v0.6.2)}"
shift || true

REF="${VERSION}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref) REF="${2:?--ref requires a value}"; shift 2;;
    *) echo "unknown argument: $1" >&2; exit 2;;
  esac
done

SPEC_REPO="https://github.com/proof-of-insight/spec.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

OUTDIR="${SITE_ROOT}/spec/${VERSION}"
mkdir -p "${OUTDIR}"

echo "Cloning ${SPEC_REPO} at ${REF}..."
if ! git clone --depth 1 --branch "${REF}" "${SPEC_REPO}" "${WORKDIR}/spec-repo" 2>/dev/null; then
  echo "Failed to clone at ref '${REF}'." >&2
  if [[ "${REF}" == "${VERSION}" ]]; then
    echo "The tag '${VERSION}' does not exist in ${SPEC_REPO}." >&2
    echo "Tag it from the spec repo (git tag ${VERSION} && git push --tags)" >&2
    echo "or pass --ref main to render an in-progress version." >&2
  fi
  exit 1
fi

SPEC_MD="${WORKDIR}/spec-repo/versions/${VERSION}.md"
if [[ ! -f "${SPEC_MD}" ]]; then
  echo "Spec source not found at versions/${VERSION}.md in the cloned repo." >&2
  exit 1
fi

echo "Rendering HTML..."
pandoc "${SPEC_MD}" \
  --from=gfm \
  --to=html5 \
  --standalone \
  --template="${SCRIPT_DIR}/pandoc-template.html5" \
  --toc --toc-depth=3 \
  --section-divs \
  --metadata title="Proof of Insight ${VERSION}" \
  --metadata version="${VERSION}" \
  --output="${OUTDIR}/index.html"

echo "Rendering PDF..."
# Map the handful of unicode math symbols used in the spec (∈ ∉ ⊂ ≥ ≤) to
# a glyph-bearing fallback font, since Spectral and JetBrains Mono don't
# cover them. Without this, xelatex emits "missing character" warnings
# and prints empty boxes.
PDF_PREAMBLE="$(mktemp)"
trap 'rm -f "${PDF_PREAMBLE}"; rm -rf "${WORKDIR}"' EXIT
cat > "${PDF_PREAMBLE}" <<'EOF'
\usepackage{newunicodechar}
\newfontfamily{\unimathfallback}{DejaVu Sans}
\newunicodechar{∈}{{\unimathfallback ∈}}
\newunicodechar{∉}{{\unimathfallback ∉}}
\newunicodechar{⊂}{{\unimathfallback ⊂}}
\newunicodechar{⊃}{{\unimathfallback ⊃}}
\newunicodechar{≥}{{\unimathfallback ≥}}
\newunicodechar{≤}{{\unimathfallback ≤}}
\newunicodechar{±}{{\unimathfallback ±}}
\newunicodechar{δ}{{\unimathfallback δ}}
\newunicodechar{′}{{\unimathfallback ′}}
EOF

pandoc "${SPEC_MD}" \
  --from=gfm \
  --pdf-engine=xelatex \
  --metadata title="Proof of Insight ${VERSION}" \
  --variable mainfont="Spectral" \
  --variable monofont="JetBrains Mono" \
  --variable geometry:margin=1in \
  --include-in-header="${PDF_PREAMBLE}" \
  --output="${OUTDIR}/poi-${VERSION}.pdf"

SCHEMA_SRC="${WORKDIR}/spec-repo/schema/${VERSION}"
if [[ -d "${SCHEMA_SRC}" ]]; then
  echo "Copying schemas..."
  mkdir -p "${SITE_ROOT}/schema/${VERSION}"
  cp -R "${SCHEMA_SRC}/." "${SITE_ROOT}/schema/${VERSION}/"
fi

echo "Rendered ${VERSION} into ${OUTDIR}/"
