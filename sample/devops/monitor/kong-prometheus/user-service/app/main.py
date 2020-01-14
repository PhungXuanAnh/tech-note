from flask import Flask

app = Flask(__name__)


@app.route("/", methods=['GET'])
def read_root():
    return {"data": ['user1', 'user2']}


@app.route("/api/user1", methods=['GET'])
def read_user1():
    return {"message": "user1 is called"}


@app.route("/api/user2", methods=['GET'])
def read_user2():
    return {"message": "user2 is called"}


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8123, debug=True)
