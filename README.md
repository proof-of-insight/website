# proofofinsight.org

Source for the Proof of Insight project website.

The site consists of a handcrafted landing page (`index.html`) and rendered specification versions under `spec/`. The rendered spec is built from the [spec repository](https://github.com/proof-of-insight/spec) by `build/render-spec.sh` at deploy time. Each rendered version is pinned to a tagged release in the spec repository, so versioned URLs (`/spec/v0.6.2/`) are immutable once published.

## Local preview

```bash
./build/render-spec.sh v0.6.2
python3 -m http.server 8080
# open http://localhost:8080/
```

The render script requires `pandoc` (and `xelatex` plus the configured fonts for PDF output; HTML works without LaTeX).

## Adding a new spec version

1. Tag the version in the [spec repository](https://github.com/proof-of-insight/spec) (for example, `git tag v0.7.0 && git push --tags`).
2. Run `./build/render-spec.sh v0.7.0` locally to verify the render.
3. Add `v0.7.0` to the version list in `.github/workflows/build-and-deploy.yml`.
4. Open a pull request. Older versions remain at their permanent URLs.

## Deployment

GitHub Pages, via `.github/workflows/build-and-deploy.yml` on push to `main` and on a daily schedule. The daily rebuild re-renders the currently published versions; because each render is pinned to a tag, the daily build is effectively a no-op unless the workflow or template changes.

## License

- Site content (landing-page prose, rendered specification): [CC BY 4.0](LICENSE)
- Site code (build scripts, Pandoc template, CI workflow): [MIT](LICENSE-CODE)
- Rendered specification text is reproduced under the spec's own license (CC BY 4.0)
