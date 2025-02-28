#!/usr/bin/env zsh

# Name of the project folder (adjust as desired)
PROJECT_NAME="rag-tester"

echo "Creating project structure..."

# 2. Create subdirectories
mkdir -p "$PROJECT_NAME/rag_pipeline"
mkdir -p "$PROJECT_NAME/tests"
mkdir -p "$PROJECT_NAME/test_cases"

# 3. Create a stub Python file for the RAG pipeline
cat <<EOF > "$PROJECT_NAME/rag_pipeline/rag_pipeline.py"
\"\"\"
Stub file for the RAG pipeline logic.
Replace this with the actual retrieval and generation code.
\"\"\"

def generate_answer(prompt: str) -> str:
    \"\"\"
    Simulate or wrap the real RAG pipeline.
    This function will retrieve relevant documents and call an LLM.
    \"\"\"
    if "capital of France" in prompt:
        return "Paris"
    elif "Pride and Prejudice" in prompt:
        return "Jane Austen"
    else:
        return "I'm not sure yet."
EOF

# 4. Create the test runner file using pytest
cat <<EOF > "$PROJECT_NAME/tests/test_rag_basic.py"
import pytest
import json
from pathlib import Path

from rag_pipeline.rag_pipeline import generate_answer

@pytest.fixture(scope="module")
def test_cases():
    test_case_file = Path(__file__).parent.parent / "test_cases" / "sample_test_cases.json"
    with open(test_case_file, "r", encoding="utf-8") as f:
        data = json.load(f)
    return data

def test_rag_responses(test_cases):
    all_results = []
    for tc in test_cases:
        prompt = tc["prompt"]
        expected = tc["expected_output"]
        test_id = tc["id"]

        generated_answer = generate_answer(prompt)
        is_correct = (expected.lower() in generated_answer.lower())

        result_entry = {
            "test_id": test_id,
            "prompt": prompt,
            "expected": expected,
            "generated": generated_answer,
            "pass": is_correct
        }
        all_results.append(result_entry)

        assert is_correct, f"Test {test_id} failed. Expected '{expected}', got '{generated_answer}'."

    generate_report(all_results)

def generate_report(results):
    report_file = Path(__file__).parent / "rag_test_report.txt"
    lines = []
    lines.append("RAG Test Report")
    lines.append("================")
    pass_count = 0

    for r in results:
        status = "PASS" if r["pass"] else "FAIL"
        if r["pass"]:
            pass_count += 1
        lines.append(f"Test ID: {r['test_id']} | Status: {status}")
        lines.append(f"  Prompt: {r['prompt']}")
        lines.append(f"  Expected: {r['expected']}")
        lines.append(f"  Generated: {r['generated']}")
        lines.append("----------------------------------------")

    total_tests = len(results)
    lines.append(f"\\nTotal tests: {total_tests}, Passed: {pass_count}, Failed: {total_tests - pass_count}")

    with open(report_file, "w", encoding="utf-8") as f:
        f.write("\\n".join(lines))

    print(f"Report generated at: {report_file.resolve()}")
EOF

# 5. Create a sample JSON file with test cases
cat <<EOF > "$PROJECT_NAME/test_cases/sample_test_cases.json"
[
  {
    "id": "test_01",
    "prompt": "What is the capital of France?",
    "expected_output": "Paris"
  },
  {
    "id": "test_02",
    "prompt": "Who wrote 'Pride and Prejudice'?",
    "expected_output": "Jane Austen"
  }
]
EOF

# 6. Create a requirements file (optional)
cat <<EOF > "$PROJECT_NAME/requirements.txt"
pytest==7.0.0
EOF

# 7. Create a minimal README
cat <<EOF > "$PROJECT_NAME/README.md"
# RAG Testing Project

This project contains:
- A simple RAG pipeline stub (rag_pipeline.py).
- A pytest-based test suite (test_rag_basic.py).
- JSON-defined test cases (sample_test_cases.json).

## Quick Start

1. Create a virtual environment and install dependencies:
   \`\`\`bash
   cd $PROJECT_NAME
   python3 -m venv venv
   source venv/bin/activate   # (on Mac/Linux with Bash or Zsh)
   pip install -r requirements.txt
   \`\`\`

2. Run tests:
   \`\`\`bash
   pytest --maxfail=1 --disable-warnings -v
   \`\`\`

3. Check the generated \`rag_test_report.txt\` in the \`tests/\` folder for the test summary.

## Next Steps
- Replace the stub RAG code with actual retrieval and generation logic.
- Add more advanced metrics or further test scenarios.
EOF

echo "Project structure created successfully at '$PROJECT_NAME'."
