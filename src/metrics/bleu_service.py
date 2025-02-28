import nltk

class BLEUService:
    def compute(self, reference: str, generated: str) -> float:
        reference_tokens = [reference.lower().split()]
        generated_tokens = generated.lower().split()
        return nltk.translate.bleu_score.sentence_bleu(reference_tokens, generated_tokens)
