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
