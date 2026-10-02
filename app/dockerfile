FROM python:3.13-alpine

WORKDIR /app

COPY app/requirments.txt .

RUN pip install --no-cache-dir -r requirments.txt

COPY app/main.py .

EXPOSE 5000

CMD ["python", "main.py"]