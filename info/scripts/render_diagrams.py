#!/usr/bin/env python3
"""Render .mmd Mermaid sources in info/diagrams/ to PNG and SVG."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

INFO_DIR = Path(__file__).resolve().parent.parent
DIAGRAMS_DIR = INFO_DIR / "diagrams"
VENDOR_DIR = INFO_DIR / "vendor"
MERMAID_JS = VENDOR_DIR / "mermaid.min.js"

HTML_TEMPLATE = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<script>{mermaid_js}</script>
<style>
  body {{ margin: 16px; background: white; }}
  .mermaid {{ font-family: sans-serif; }}
</style>
</head>
<body>
<div class="mermaid">
{content}
</div>
<script>
  mermaid.initialize({{ startOnLoad: true, theme: "default", securityLevel: "loose" }});
</script>
</body>
</html>
"""


def ensure_mermaid_js() -> None:
    """Download mermaid.js once for offline renders."""
    if MERMAID_JS.exists():
        return

    VENDOR_DIR.mkdir(parents=True, exist_ok=True)
    url = "https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"
    print(f"Downloading {url} ...")
    try:
        from urllib.request import urlopen

        MERMAID_JS.write_bytes(urlopen(url, timeout=60).read())
    except Exception as exc:  # noqa: BLE001
        raise SystemExit(
            f"Failed to download mermaid.js: {exc}\n"
            "Check network access or place mermaid.min.js in info/vendor/"
        ) from exc


def render_one(mmd_path: Path, png_path: Path, svg_path: Path) -> None:
    from playwright.sync_api import sync_playwright

    ensure_mermaid_js()
    content = mmd_path.read_text(encoding="utf-8")
    html = HTML_TEMPLATE.format(
        mermaid_js=MERMAID_JS.read_text(encoding="utf-8"),
        content=content,
    )

    with sync_playwright() as playwright:
        browser = playwright.chromium.launch()
        page = browser.new_page(viewport={"width": 1400, "height": 900})
        page.set_content(html, wait_until="networkidle")
        page.wait_for_selector(".mermaid svg", timeout=60000)
        svg = page.locator(".mermaid svg").first
        svg.screenshot(path=str(png_path))
        svg_html = svg.evaluate("el => el.outerHTML")
        svg_path.write_text(
            '<?xml version="1.0" encoding="UTF-8"?>\n' + svg_html,
            encoding="utf-8",
        )
        browser.close()

    print(f"  PNG  {png_path.relative_to(INFO_DIR)}")
    print(f"  SVG  {svg_path.relative_to(INFO_DIR)}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--all",
        action="store_true",
        help="Render every .mmd file in info/diagrams/",
    )
    parser.add_argument("names", nargs="*", help="Basenames without extension, e.g. memory-map")
    args = parser.parse_args()

    if args.all or not args.names:
        mmd_files = sorted(DIAGRAMS_DIR.glob("*.mmd"))
    else:
        mmd_files = [DIAGRAMS_DIR / f"{name}.mmd" for name in args.names]

    if not mmd_files:
        print("No .mmd files found.", file=sys.stderr)
        return 1

    print("Rendering Mermaid diagrams...")
    for mmd_path in mmd_files:
        if not mmd_path.exists():
            print(f"Missing {mmd_path}", file=sys.stderr)
            return 1
        stem = mmd_path.stem
        print(stem + ":")
        render_one(
            mmd_path,
            DIAGRAMS_DIR / f"{stem}.png",
            DIAGRAMS_DIR / f"{stem}.svg",
        )

    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
