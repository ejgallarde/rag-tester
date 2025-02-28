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
    lines.append(f"\nTotal tests: {total_tests}, Passed: {pass_count}, Failed: {total_tests - pass_count}")

    with open(report_file, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print(f"Report generated at: {report_file.resolve()}")
