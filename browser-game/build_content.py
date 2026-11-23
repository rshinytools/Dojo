"""Generate the browser game's runtime data from the portable design snapshot."""

import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
source = HERE.parent / "design" / "world-content.json"
data = json.loads(source.read_text(encoding="utf-8"))
(HERE / "content.js").write_text(
    "window.BEAST_CONTENT = " + json.dumps(data, indent=2, ensure_ascii=False) + ";\n",
    encoding="utf-8",
)
