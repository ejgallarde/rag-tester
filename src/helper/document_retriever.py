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
        return "\n".join(text_content)
