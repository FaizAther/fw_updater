# info/

Reference documentation for the **fw_upgrade** project (NUCLEO-F401RE).

## Start here

| Document | Best for |
|----------|----------|
| **[linker-guide.md](linker-guide.md)** | **Full tutorial** — compiler vs linker vs chip, sections, sizes, vector table, your real addresses |
| [linker-script-and-memory.md](linker-script-and-memory.md) | Shorter reference for `app/app.ld` and memory map |

## Diagram sources & rendered images

Run `./render.sh` to regenerate PNG/SVG from `.mmd` files.

| Diagram | PNG |
|---------|-----|
| Build pipeline | [build-pipeline.png](diagrams/build-pipeline.png) |
| Object file sections | [object-sections.png](diagrams/object-sections.png) |
| Linker role | [linker-role.png](diagrams/linker-role.png) |
| VMA vs LMA | [vma-lma.png](diagrams/vma-lma.png) |
| Detailed memory map | [detailed-memory-map.png](diagrams/detailed-memory-map.png) |
| Vector table | [vector-table.png](diagrams/vector-table.png) |
| Boot sequence | [boot-sequence.png](diagrams/boot-sequence.png) |
| Memory map (overview) | [memory-map.png](diagrams/memory-map.png) |

Sources: `diagrams/*.mmd` (Mermaid) · `diagrams/*.drawio` (editable in diagrams.net)

## Render diagrams locally

```sh
cd info
./render.sh          # creates .venv, installs deps, outputs .png + .svg
```

- Python venv: `info/.venv/` (gitignored)
- Packages: [requirements.txt](requirements.txt) — `playwright`, `Pillow`
- Downloads: Chromium (Playwright) + `vendor/mermaid.min.js` on first run

**Chat vs local:** Cursor chat renders ` ```mermaid ` blocks inline — no PNG files. Use `./render.sh` for images on disk.
