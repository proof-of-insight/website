# proofofinsight.org

Source for the Proof of Insight project website.

The site consists of a handcrafted landing page (`index.html`) and rendered specification versions under `spec/`. The rendered spec is built from the [spec repository](https://github.com/proof-of-insight/spec) by `build/render-spec.sh` at deploy time. Each rendered version is pinned to a tagged release in the spec repository, so versioned URLs (`/spec/v0.6.2/`) are immutable once published.

## Local preview

```bash
./build/render-spec.sh v0.7.0
python3 -m http.server 8080
# open http://localhost:8080/
```

The render script requires `pandoc` (and `xelatex` plus the configured fonts for PDF output; HTML works without LaTeX).

## Adding a new spec version

See [RELEASING.md](https://github.com/proof-of-insight/spec/blob/main/RELEASING.md) in the spec repository for the full procedure. In brief, for a new version `vX.Y.Z`:

1. Tag the version (signed) in the [spec repository](https://github.com/proof-of-insight/spec): `git tag -s vX.Y.Z && git push origin vX.Y.Z`.
2. Run `./build/render-spec.sh vX.Y.Z` locally to verify the render.
3. Add `vX.Y.Z` to `SPEC_VERSIONS` in `.github/workflows/build-and-deploy.yml`, and update `index.html` to point at the new version.
4. Open a pull request. Older versions remain at their permanent URLs.

## Deployment

GitHub Pages, via `.github/workflows/build-and-deploy.yml` on push to `main` and on a daily schedule. The daily rebuild re-renders the currently published versions; because each render is pinned to a tag, the daily build is effectively a no-op unless the workflow or template changes.

## License

- Site content (landing-page prose, rendered specification): [CC BY 4.0](LICENSE)
- Site code (build scripts, Pandoc template, CI workflow): [MIT](LICENSE-CODE)
- Rendered specification text is reproduced under the spec's own license (CC BY 4.0)
