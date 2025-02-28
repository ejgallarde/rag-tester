class JaccardService:
    def compute(self, reference: str, generated: str) -> float:
        ref_words = set(reference.lower().split())
        gen_words = set(generated.lower().split())
        intersection = ref_words.intersection(gen_words)
        union = ref_words.union(gen_words)
        return len(intersection) / len(union) if len(union) > 0 else 0.0
