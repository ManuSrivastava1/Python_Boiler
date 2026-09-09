# Python_Boiler
Bash script for creating a lightweight Python project boilerplate.

Running the script creates the following layout:
```
my_project/
├── pyproject.toml
├── requirements.txt
├── requirements-dev.txt
├── .gitignore
├── README.md
│
├── .venv/
│
├── src/
│   └── main.py
│   
│
└── tests/
    ├── __init__.py
    └── test_main.py
```

## Usage 

```bash
./boiler.sh my_project
```
```bash
./boiler.sh my_project --author "Jane Doe" --description "A tool that does things" --python-version 3.11
```
