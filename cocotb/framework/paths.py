"""Repository path anchors, resolved once from this file's location.

The cocotb framework lives at ``<repo>/cocotb/framework``, so every anchor here
is derived from ``__file__`` — IP runners never hand-roll ``../../..`` chains,
and there is a single source of truth for where the repo root is.

    from framework.paths import REPO_ROOT, COCOTB_DIR
"""

from __future__ import annotations

from pathlib import Path

FRAMEWORK_DIR = Path(__file__).resolve().parent   # <repo>/cocotb/framework
COCOTB_DIR = FRAMEWORK_DIR.parent                 # <repo>/cocotb
REPO_ROOT = COCOTB_DIR.parent                     # <repo>
