#!/bin/zsh


# ------------------------------------------------------------
# 1. CREATE / UPDATE SUBFOLDER STRUCTURE
# ------------------------------------------------------------

echo "Creating or updating subfolders in rag-tester..."

mkdir -p src/metrics
mkdir -p temp_documents

echo "Subfolder structure created/verified."


# ------------------------------------------------------------
# 2. ADD / UPDATE PYTHON FILE STUBS
# ------------------------------------------------------------

echo "Generating DocumentRetriever stub..."
cat <<EOF > src/document_retriever.py
import os
import PyPDF2

class DocumentRetriever:
    def __init__(self, directory_path: str):
        self.directory_path = directory_path

    def retrieve_documents(self):
        texts = []
        for filename in os.listdir(self.directory_path):
            filepath = os.path.join(self.directory_path, filename)
            if filename.endswith(".pdf"):
                texts.append(self._pdf_to_text(filepath))
            elif filename.endswith(".txt"):
                with open(filepath, 'r', encoding='utf-8') as f:
                    texts.append(f.read())
        return texts

    def _pdf_to_text(self, pdf_path: str) -> str:
        text_content = []
        with open(pdf_path, 'rb') as f:
            reader = PyPDF2.PdfReader(f)
            for page in reader.pages:
                page_text = page.extract_text()
                if page_text:
                    text_content.append(page_text)
        return "\\n".join(text_content)
EOF

echo "Generating LLMStub stub..."
cat <<EOF > src/llm_stub.py
class LLMStub:
    def __init__(self):
        pass

    def generate_answer(self, prompt: str) -> str:
        return f"LLM answer for prompt: {prompt[:60]}..."
EOF

echo "Generating Metrics Services..."

# Semantic Similarity
cat <<EOF > src/metrics/semantic_similarity_service.py
import numpy as np
from sentence_transformers import SentenceTransformer, util

class SemanticSimilarityService:
    def __init__(self, model_name="all-MiniLM-L6-v2"):
        self.model = SentenceTransformer(model_name)

    def compute(self, reference: str, generated: str) -> float:
        ref_embedding = self.model.encode(reference, convert_to_tensor=True)
        gen_embedding = self.model.encode(generated, convert_to_tensor=True)
        similarity = util.cos_sim(ref_embedding, gen_embedding)
        return float(similarity[0][0].item())
EOF

# Readability
cat <<EOF > src/metrics/readability_service.py
import textstat

class ReadabilityService:
    def compute(self, text: str) -> float:
        return textstat.flesch_reading_ease(text)
EOF

# Jaccard
cat <<EOF > src/metrics/jaccard_service.py
class JaccardService:
    def compute(self, reference: str, generated: str) -> float:
        ref_words = set(reference.lower().split())
        gen_words = set(generated.lower().split())
        intersection = ref_words.intersection(gen_words)
        union = ref_words.union(gen_words)
        return len(intersection) / len(union) if len(union) > 0 else 0.0
EOF

# BLEU
cat <<EOF > src/metrics/bleu_service.py
import nltk

class BLEUService:
    def compute(self, reference: str, generated: str) -> float:
        reference_tokens = [reference.lower().split()]
        generated_tokens = generated.lower().split()
        return nltk.translate.bleu_score.sentence_bleu(reference_tokens, generated_tokens)
EOF

# Asymmetric Topical Relevance
cat <<EOF > src/metrics/asymmetric_topical_relevance_service.py
import spacy

class AsymmetricTopicalRelevanceService:
    def __init__(self, model_name="en_core_web_sm"):
        self.nlp = spacy.load(model_name)
    
    def extract_keywords(self, text: str) -> set:
        doc = self.nlp(text)
        keywords = {token.lemma_.lower() for token in doc if token.pos_ in ["NOUN", "PROPN"]}
        return keywords

    def compute(self, reference: str, generated: str) -> float:
        reference_keywords = self.extract_keywords(reference)
        generated_words = set(generated.lower().split())
        overlap = len(reference_keywords.intersection(generated_words))
        return float(overlap / len(reference_keywords)) if reference_keywords else 0.0
EOF

echo "Generating Test Pipeline stub..."
cat <<EOF > src/test_pipeline.py
from document_retriever import DocumentRetriever
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
        combined_docs_text = "\\n\\n".join(docs_content)

        prompt = f"Please answer the following question using this document context:\\n{combined_docs_text}\\n\\nQuestion: {self.reference_text}"
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
            print("\\nALL TESTS PASSED!")
        else:
            print("\\nSOME TESTS DID NOT PASS.")

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
EOF

echo "All new stubs have been created/updated in 'rag-tester'. Setup additions complete!"
