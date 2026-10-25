import os
import random
import re
import socket

import redis
from flask import Flask, jsonify, render_template, request

app = Flask(__name__)

redis_client = redis.Redis(
    host=os.getenv("REDIS_HOST", "redis_client"),
    port=int(os.getenv("REDIS_PORT", "6379")),
    decode_responses=True,
)

REACTIONS = [
    {"emoji": "🚀", "label": "Shipped it"},
    {"emoji": "🐳", "label": "Container victory"},
    {"emoji": "🔥", "label": "On a roll"},
    {"emoji": "⚡", "label": "Quick fix"},
    {"emoji": "🧠", "label": "Eureka moment"},
    {"emoji": "🛠️", "label": "Debugging complete"},
    {"emoji": "🎯", "label": "Nailed it"},
    {"emoji": "💪", "label": "Kept going"},
]


@app.route("/")
def home():
    return render_template("index.html")


@app.route("/about")
def about():
    return render_template("about.html")


@app.route("/stats")
def stats_page():
    return render_template("stats.html")


# Retained for compatibility with the original CoderCo assignment.
@app.route("/count")
def count():
    visits = redis_client.incr("visits")
    return f"Visit count: {visits} | Container: {socket.gethostname()}"


@app.post("/api/click")
def click():
    payload = request.get_json(silent=True) or {}
    guest_id = payload.get("guest_id", "")
    if not isinstance(guest_id, str) or not re.fullmatch(r"[a-f0-9]{12}", guest_id):
        return jsonify({"error": "Invalid anonymous visitor ID"}), 400

    previous = redis_client.get("last_reaction")
    reaction = random.choice([item for item in REACTIONS if item["emoji"] != previous])
    guest = f"Guest-{guest_id[:6].upper()}"
    transaction = redis_client.pipeline(transaction=True)
    transaction.incr("visits")
    transaction.hincrby("emoji_counts", reaction["emoji"], 1)
    transaction.zincrby("guest_scores", 1, guest)
    transaction.set("last_reaction", reaction["emoji"])
    total, _, score, _ = transaction.execute()

    return jsonify({
        "total": total,
        "reaction": reaction,
        "your_clicks": int(score),
        "guest": guest,
        "container": socket.gethostname(),
    })


@app.get("/api/stats")
def stats_api():
    counts = redis_client.hgetall("emoji_counts")
    leaderboard = redis_client.zrevrange("guest_scores", 0, 9, withscores=True)
    return jsonify({
        "total": int(redis_client.get("visits") or 0),
        "emoji_total": sum(int(value) for value in counts.values()),
        "reactions": [
            {"emoji": item["emoji"], "label": item["label"], "count": int(counts.get(item["emoji"], 0))}
            for item in REACTIONS
        ],
        "leaderboard": [
            {"guest": guest, "clicks": int(score)}
            for guest, score in leaderboard
        ],
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
