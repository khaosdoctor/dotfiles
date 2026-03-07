# Obsidian Image Handling

## coverUrl Property

- The `coverUrl` frontmatter property must be a **web URL** (e.g. a Wikimedia Commons link), never a local asset path.
- Example: `coverUrl: https://upload.wikimedia.org/wikipedia/commons/6/6a/Johann_Sebastian_Bach.jpg`

## Images in Note Body

- Images displayed in the note body must be **downloaded locally** into `internal/assets/` using kebab-case naming (e.g. `leonard-bernstein.jpg`, `middle-c.png`).
- Use the Obsidian wikilink embed syntax: `![[filename.ext|Description|size]]`
- Example: `![[johann-sebastian-bach.jpg|Johann Sebastian Bach|350]]`
- Do NOT use external URLs for images in the note body - Obsidian may fail to render them.

## Download Procedure

1. Find the correct image URL via the Wikipedia API:
   ```bash
   # Get the main image for a Wikipedia page
   curl -sL -A "Mozilla/5.0" "https://en.wikipedia.org/w/api.php?action=query&titles=<Page_Title>&prop=pageimages&format=json&pithumbsize=500"
   ```
   Or for a specific file:
   ```bash
   # Get the actual URL for a known filename
   curl -sL -A "Mozilla/5.0" "https://en.wikipedia.org/w/api.php?action=query&titles=File:<Filename>&prop=imageinfo&iiprop=url&format=json"
   ```

2. Download the image with a User-Agent header:
   ```bash
   curl -sL -A "Mozilla/5.0" -o "internal/assets/<kebab-name>.<ext>" "<url>"
   ```

3. Verify the download is an actual image (not HTML):
   ```bash
   file "internal/assets/<kebab-name>.<ext>"
   ```

4. If the result says "HTML" or "ASCII text", the URL is broken - use the API to find the correct one.

## Fallback: Image Not Found

If the Wikipedia API returns no image for a page (no `pageimage` field in the response):

1. Search the web for a public domain or freely licensed image:
   ```
   WebSearch: "<subject name> portrait photo Wikimedia Commons"
   ```
2. Check Wikimedia Commons directly for categories related to the subject.
3. If a suitable image is found, download it following the same procedure above.
4. If no image can be found at all, set `coverUrl: ""` in the frontmatter and omit the image embed from the note body entirely.

## Transparency Removal (MANDATORY)

The vault uses a dark theme. **All downloaded images MUST have transparency removed** before use. Transparent PNGs (common from Wikimedia SVG renders, score images, and diagrams) will appear as black-on-black and be invisible.

After downloading any PNG, **always** run:

```bash
magick "<file>.png" -background white -alpha remove -type TrueColor "PNG24:<file>.png"
```

Then verify:

```bash
magick identify -format '%[channels]' "<file>.png"
# Must show "srgb  3.0" — NOT "graya", "srgba", or "gray"
```

### Why PNG24?

- `PNG24:` forces RGB output with no alpha channel — it is physically impossible for the resulting file to have transparency.
- `-background white -alpha remove` alone is not always enough — ImageMagick may still write an alpha channel in the output.
- `-type TrueColor` prevents grayscale output, which some renderers handle poorly on dark backgrounds.

### When to apply

- **Every** PNG downloaded from the web, no exceptions.
- SVG-to-PNG conversions (Wikimedia `/thumb/.../500px-....svg.png` URLs always have alpha).
- Wikimedia score images (`/score/...`) always have alpha.
- JPEGs do not support transparency, so they are safe as-is.

## coverUrl and SVGs

- The `coverUrl` property must be a **web URL**, never a local path.
- **Never use SVG URLs** for `coverUrl` — they have transparent backgrounds and cannot be fixed server-side.
- If the source image is an SVG, use the Wikimedia PNG thumbnail URL instead:
  ```
  # SVG (bad):
  https://upload.wikimedia.org/wikipedia/commons/c/c2/All_clefs.svg

  # PNG thumbnail (good):
  https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/All_clefs.svg/500px-All_clefs.svg.png
  ```
- Note: these PNG thumbnails from SVGs still have transparency, but coverUrl is rendered by Obsidian's theme and is generally acceptable. The body images are the critical ones.

## Common Pitfalls

- Wikimedia **thumbnail URLs** (`/thumb/.../440px-...`) often return 404 or HTML. Prefer full-resolution URLs or use the Wikipedia API to get working URLs.
- Always verify downloads with `file` command before committing.
- When downloading from non-Wikimedia sources, ensure the image is freely licensed or public domain.
- **Never skip the transparency removal step** — even if the image "looks fine" on a light background, it will be invisible on dark themes.
