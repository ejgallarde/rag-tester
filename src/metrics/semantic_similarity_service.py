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
