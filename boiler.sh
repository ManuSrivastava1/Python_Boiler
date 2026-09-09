#!/usr/bin/env bash
#
# Scaffold a Python project with a src/ layout.
#
# Usage:
#   ./boiler.sh my_project
#   ./boiler.sh my_project --author "Jane Doe" --description "A tool that does things" --python-version 3.11
#
#confirm the files in terminal
#   find "my_project" -type f

set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 <project_name> [options]

Options:
  --author NAME            Author name for pyproject.toml (default: "")
  --description TEXT       One-line project description (default: "")
  --python-version VER     Minimum Python version (default: 3.10)
  --path DIR                Directory in which to create the project (default: .)
  -h, --help                Show this help message
EOF
    exit 1
}

[[ $# -ge 1 ]] || usage

PROJECT_NAME="$1"
shift

# --- Locate a Python interpreter ---
PYTHON_BIN=""
for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c "" >/dev/null 2>&1; then
        PYTHON_BIN="$candidate"
        break
    fi
done

if [[ -z "$PYTHON_BIN" ]]; then
    echo "Error: no working python3/python interpreter found on PATH" >&2
    exit 1
fi

AUTHOR=""
DESCRIPTION=""
#PYTHON_VERSION="3.10"
PYTHON_VERSION=$("$PYTHON_BIN" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
BASE_PATH="."

while [[ $# -gt 0 ]]; do
    case "$1" in
        --author) AUTHOR="$2"; shift 2 ;;
        --description) DESCRIPTION="$2"; shift 2 ;;
        --python-version) PYTHON_VERSION="$2"; shift 2 ;;
        --path) BASE_PATH="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1" >&2; usage ;;
    esac
done

PROJECT_DIR="${BASE_PATH}/${PROJECT_NAME}"

if [[ -d "$PROJECT_DIR" ]] && [[ -n "$(ls -A "$PROJECT_DIR" 2>/dev/null)" ]]; then
    echo "Error: $PROJECT_DIR already exists and is not empty" >&2
    exit 1
fi

SRC_DIR="${PROJECT_DIR}/src"
TESTS_DIR="${PROJECT_DIR}/tests"

mkdir -p "$SRC_DIR" "$TESTS_DIR"

# --- pyproject.toml ---
cat > "${PROJECT_DIR}/pyproject.toml" <<EOF
[build-system]
requires = ["setuptools>=68.0"]
build-backend = "setuptools.build_meta"

[project]
name = "${PROJECT_NAME}"
version = "0.1.0"
description = "${DESCRIPTION}"
readme = "README.md"
requires-python = ">=${PYTHON_VERSION}"
authors = [
    { name = "${AUTHOR}" }
]
dependencies = []

[project.optional-dependencies]
dev = [
    "pytest",
    "ruff",
]

[tool.setuptools]
packages = ["src"]

[tool.pytest.ini_options]
testpaths = ["tests"]

[tool.ruff]
line-length = 100
EOF

# --- requirements.txt ---
cat > "${PROJECT_DIR}/requirements.txt" <<EOF
# Runtime dependencies
EOF

# --- requirements-dev.txt ---
cat > "${PROJECT_DIR}/requirements-dev.txt" <<EOF
-r requirements.txt
pytest
ruff
EOF

# --- .gitignore ---
cat > "${PROJECT_DIR}/.gitignore" <<EOF
__pycache__/
*.py[cod]
*.egg-info/
.eggs/
build/
dist/

.venv/
venv/
env/

.pytest_cache/
.mypy_cache/
.ruff_cache/
.coverage
htmlcov/

.env
.vscode/
.idea/
EOF

# --- README.md ---
cat > "${PROJECT_DIR}/README.md" <<EOF
# ${PROJECT_NAME}

## Overview
${DESCRIPTION:-TODO: describe this project.}

## Setup

\`\`\`bash
python -m venv .venv
source .venv/bin/activate  # on Windows: .venv\\Scripts\\activate
pip install -r requirements.txt -r requirements-dev.txt
pip install -e .
\`\`\`

## Usage

\`\`\`bash
python -m src.main
\`\`\`

## Tests

\`\`\`bash
pytest
\`\`\`
EOF

# --- src/__init__.py ---
touch "${SRC_DIR}/__init__.py"

# --- src/main.py ---
cat > "${SRC_DIR}/main.py" <<EOF
import sys

def main() -> None:
    print("Hello from ${PROJECT_NAME}!")
    return 0

if __name__ == "__main__":
    sys.exit(main())
EOF

# --- tests/__init__.py ---
touch "${TESTS_DIR}/__init__.py"

# --- tests/test_main.py ---
cat > "${TESTS_DIR}/test_main.py" <<EOF
from src.main import main


def test_main(capsys):
    main()
    captured = capsys.readouterr()
    assert "Hello" in captured.out
EOF

echo "Created project at $(cd "$PROJECT_DIR" && pwd)"
echo "  source: src/"


# --- Create the virtual environment ---
"$PYTHON_BIN" -m venv "${PROJECT_DIR}/.venv"
