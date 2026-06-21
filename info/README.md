# info/

Reference documentation for the **fw_upgrade** project.

| Document | Description |
|----------|-------------|
| [linker-script-and-memory.md](linker-script-and-memory.md) | Full write-up: `app/app.ld`, ROM/RAM map, boot flow, NUCLEO-F401RE |

## Diagram sources & rendered images

| Source | Rendered (PNG / SVG) | Editable (draw.io) |
|--------|----------------------|---------------------|
| [diagrams/memory-map.mmd](diagrams/memory-map.mmd) | [memory-map.png](diagrams/memory-map.png) · [memory-map.svg](diagrams/memory-map.svg) | [memory-map.drawio](diagrams/memory-map.drawio) |
| [diagrams/boot-sequence.mmd](diagrams/boot-sequence.mmd) | [boot-sequence.png](diagrams/boot-sequence.png) · [boot-sequence.svg](diagrams/boot-sequence.svg) | [boot-sequence.drawio](diagrams/boot-sequence.drawio) |

**Chat vs local:** Cursor chat renders ` ```mermaid ` blocks in Markdown automatically — no PNG files involved. To get images on disk, use the venv below.

## Render diagrams locally

```sh
cd info
./render.sh          # creates .venv, installs deps, outputs .png + .svg
# or manually:
source .venv/bin/activate
python scripts/render_diagrams.py --all
```

Setup (first time only):

- Python venv: `info/.venv/` (gitignored)
- Packages: `playwright`, `Pillow` — see [requirements.txt](requirements.txt)
- Downloads: Chromium (Playwright) + `vendor/mermaid.min.js` on first run

Open `.drawio` files at [diagrams.net](https://app.diagrams.net) or with a Draw.io VS Code extension (not auto-exported to PNG yet).
