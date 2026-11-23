"""Build an offline single HTML file with the same game code as the private Site."""
from pathlib import Path

HERE = Path(__file__).resolve().parent
page = (HERE / "index.html").read_text()
page = page.replace('<link rel="stylesheet" href="game.css">', '<style>\n' + (HERE / "game.css").read_text() + '</style>')
for name in ["content.js", "engine.js", "art.js", "game.js"]:
    marker = f'<script defer src="{name}"></script>'
    page = page.replace(marker, "", 1)
    script = (HERE / name).read_text().replace("</script", "<\\/script")
    page = page.replace("</body>", "<script>\n" + script + "</script>\n</body>")
(HERE / "Beast_Dojo.html").write_text(page)
