from flask import Flask, request, jsonify
import face_recognition
import numpy as np
import os

app = Flask(__name__)

@app.route("/generate-embedding", methods=["POST"])
def generate_embedding():
    user_id = int(request.form['user_id'])
    photo_file = request.files['photo']
    
    img = face_recognition.load_image_file(photo_file)
    encodings = face_recognition.face_encodings(img)

    if not encodings:
        return jsonify({'embedding': None, 'message': 'Wajah tidak terdeteksi'})

    embedding = encodings[0]
    os.makedirs("embeddings", exist_ok=True)
    np.save(f"embeddings/{user_id}_embedding.npy", embedding)

    return jsonify({'embedding': embedding.tolist()})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
