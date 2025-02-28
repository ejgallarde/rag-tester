class LLMStub:
    def __init__(self):
        pass

    def generate_answer(self, prompt: str) -> str:
        return f"LLM answer for prompt: {prompt[:60]}..."
