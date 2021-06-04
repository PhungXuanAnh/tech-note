from flask import Flask, jsonify, abort, make_response, request, url_for
import os
import sys
import json
import requests
# from zappa.asynchronous import task   # create background task using zappa


app = Flask(__name__)

# @task
def do_something___in_background(data_from_slash_command):
    text_after_command = data_from_slash_command.get('text', '')
    # result_after_do_something_here = do_something_for_example_call_to_3_party_service here

    slack_channel_url = data_from_slash_command.get('response_url')
    data_return_to_slack_channel = {
        "response_type": "in_channel",
        "text": "result_after_do_something_here:  " + text_after_command
    }
    response = requests.post(
        url=slack_channel_url,
        headers={'Content-Type': 'application/json'},
        json=data_return_to_slack_channel
    )
    print(response.status_code)
    print(response.text)


@app.route('/test1', methods=['POST', "GET"])
def test1():
    data_from_slash_command = request.form
    print("Data from slash command: ====> %s\n" % json.dumps(data_from_slash_command.to_dict(flat=False), indent=4, sort_keys=True))
    
    # do something that slash command want here
    # this task should be happend in background for avoid blocking slash command (max: 3s)
    # if more than 3s, it will lead to error
    do_something___in_background(data_from_slash_command)

    return jsonify(text="hello ! this is repsonse from api server after get your test1 command. I'm doing what you want.."), 200    # this message will be show Only visible to you
    # return '', 200  # Don't show anything, just acknowledge response to confirm that api have received this command
    # Reference: https://api.slack.com/interactivity/slash-commands#responding_to_commands

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8002, debug=True)