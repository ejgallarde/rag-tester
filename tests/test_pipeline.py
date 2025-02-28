from src.helper.document_retriever import DocumentRetriever
from llm_stub import LLMStub

from metrics.semantic_similarity_service import SemanticSimilarityService
from metrics.readability_service import ReadabilityService
from metrics.jaccard_service import JaccardService
from metrics.bleu_service import BLEUService
from metrics.asymmetric_topical_relevance_service import AsymmetricTopicalRelevanceService

class TestPipeline:
    def __init__(
        self,
        docs_path: str,
        reference_text: str,
        semantic_sim_threshold: float = 0.7,
        readability_threshold: float = 30.0,
        jaccard_threshold: float = 0.3,
        bleu_threshold: float = 0.4,
        topical_relevance_threshold: float = 0.5
    ):
        self.docs_path = docs_path
        self.reference_text = reference_text
        self.semantic_sim_threshold = semantic_sim_threshold
        self.readability_threshold = readability_threshold
        self.jaccard_threshold = jaccard_threshold
        self.bleu_threshold = bleu_threshold
        self.topical_relevance_threshold = topical_relevance_threshold

        self.doc_retriever = DocumentRetriever(docs_path)
        self.llm = LLMStub()
        self.semantic_service = SemanticSimilarityService()
        self.readability_service = ReadabilityService()
        self.jaccard_service = JaccardService()
        self.bleu_service = BLEUService()
        self.topical_service = AsymmetricTopicalRelevanceService()

    def run_test(self):
        docs_content = self.doc_retriever.retrieve_documents()
        combined_docs_text = "\n\n".join(docs_content)

        prompt = f"Please answer the following question using this document context:\n{combined_docs_text}\n\nQuestion: {self.reference_text}"
        generated_answer = self.llm.generate_answer(prompt)

        semantic_sim_score = self.semantic_service.compute(self.reference_text, generated_answer)
        readability_score = self.readability_service.compute(generated_answer)
        jaccard_score = self.jaccard_service.compute(self.reference_text, generated_answer)
        bleu_score = self.bleu_service.compute(self.reference_text, generated_answer)
        topical_score = self.topical_service.compute(self.reference_text, generated_answer)

        print("======== EVALUATION METRICS ========")
        print(f"Semantic Similarity: {semantic_sim_score:.3f} | Threshold: {self.semantic_sim_threshold}")
        print(f"Readability (Flesch): {readability_score:.3f}    | Threshold: {self.readability_threshold}")
        print(f"Jaccard: {jaccard_score:.3f}                    | Threshold: {self.jaccard_threshold}")
        print(f"BLEU: {bleu_score:.3f}                         | Threshold: {self.bleu_threshold}")
        print(f"Topical Relevance: {topical_score:.3f}          | Threshold: {self.topical_relevance_threshold}")

        all_pass = True
        if semantic_sim_score < self.semantic_sim_threshold:
            all_pass = False
            print("FAIL: Semantic similarity is below threshold.")
        if readability_score < self.readability_threshold:
            all_pass = False
            print("FAIL: Readability is below threshold.")
        if jaccard_score < self.jaccard_threshold:
            all_pass = False
            print("FAIL: Jaccard similarity is below threshold.")
        if bleu_score < self.bleu_threshold:
            all_pass = False
            print("FAIL: BLEU score is below threshold.")
        if topical_score < self.topical_relevance_threshold:
            all_pass = False
            print("FAIL: Topical relevance is below threshold.")

        if all_pass:
            print("\nALL TESTS PASSED!")
        else:
            print("\nSOME TESTS DID NOT PASS.")

if __name__ == "__main__":
    reference_text = "Explain how the new product launch addresses market needs."
    test_pipeline = TestPipeline(
        docs_path="./temp_documents",
        reference_text=reference_text,
        semantic_sim_threshold=0.7,
        readability_threshold=40.0,
        jaccard_threshold=0.2,
        bleu_threshold=0.3,
        topical_relevance_threshold=0.5
    )
    test_pipeline.run_test()
