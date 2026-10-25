
import os
import socket

from flask import Flask, render_template
import redis

app = Flask(__name__)

redis_client = redis.Redis(
    host=os.getenv("REDIS_HOST", "redis"),
    port=int(os.getenv("REDIS_PORT", "6379")),
    decode_responses=True
)

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/count")
def count():
    visits = redis_client.incr("visits")
    hostname = socket.gethostname()

    return f"Visit count: {visits} | Container: {hostname}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
