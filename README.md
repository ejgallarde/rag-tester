# RAG Testing Project

This project provides a skeleton test harness for a Retrieval-Augmented Generation (RAG) application. It includes:

- A **RAG pipeline stub** (`rag_pipeline/rag_pipeline.py`) you can replace with real retrieval + LLM logic.  
- A **Pytest-based test suite** (`tests/test_rag_basic.py`) that reads test cases from JSON and compares generated outputs to expected outputs.  
- **JSON-defined test cases** (`test_cases/sample_test_cases.json`) to demonstrate how to structure test inputs and expected results.  
- A **basic test report** generated as a text file (`rag_test_report.txt`).

## Project Structure

```text
my_rag_testing_project/
├── rag_pipeline/
│   └── rag_pipeline.py          # Placeholder or real RAG pipeline logic
├── tests/
│   ├── test_rag_basic.py        # Pytest suite that runs RAG tests
│   └── rag_test_report.txt      # Test report generated after tests run (ignored by Git)
├── test_cases/
│   └── sample_test_cases.json   # Example test cases in JSON
├── requirements.txt             # Python dependencies
├── .gitignore                   # Common ignores for Python, test logs, etc.
└── README.md                    # This documentation

## HOW TO RUN:
python -m pytest --maxfail=1 --disable-warnings -v

Example RAG Test Report
================
Test ID: test_01 | Status: PASS
  Prompt: What is the capital of France?
  Expected: Paris
  Generated: Paris
----------------------------------------
...

## FAQs

1. Can I run these tests without a real RAG pipeline?
Yes, as demonstrated by the stub. You can gradually replace the stub with the actual retrieval and generation logic once it’s ready.