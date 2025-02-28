import textstat

class ReadabilityService:
    def compute(self, text: str) -> float:
        return textstat.flesch_reading_ease(text)
