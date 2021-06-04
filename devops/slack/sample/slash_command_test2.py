from flask import Flask, jsonify, abort, make_response, request, url_for
import os
import sys
import json
import requests
from common import *
# from zappa.asynchronous import task   # create background task using zappa, when deploy with aws lambda


app = Flask(__name__)
app.add_url_rule('/interactivity', view_func=slack_interactivity_handler, methods=['GET', 'POST'])


# @task
def send_dialog_to_slack_app___in_background(data):
    """
        This method define how a dialog is show in slack app
        NOTE: check meaning of error message of this api here: https://api.slack.com/methods/dialog.open#errors
    """
    response = requests.post(
        url="https://slack.com/api/dialog.open",
        headers={
            'Content-Type': 'application/json',
            "Authorization": "Bearer " + APP_TOKEN
        },
        json={
            'trigger_id': data.get('trigger_id'),
            'dialog': {
                "callback_id": "ryde-46e2b0",
                "title": "This is dialog for test",
                "submit_label": "Request",
                "state": "Limo",
                "elements": [
                    {
                        "type": "text",
                        "label": "Enter any text you want :",
                        "name": "text_input"
                    },
                    {
                        "label": "Choose a value :",
                        "type": "select",
                        "name": "select_box",
                        "options": [
                            {
                                "label": "label 1",
                                "value": "value 1"
                            },
                            {
                                "label": "label 2",
                                "value": "value 2"
                            },
                            {
                                "label": "label 3",
                                "value": "value 3"
                            }
                        ]
                    },
                    {
                        "label": "Enter as many as text you want here :",
                        "name": "textarea_input",
                        "type": "textarea",
                        "hint": "Provide additional information if needed."
                    }
                ]
            }
        }
    )
    print('Send dialog status_code: {}'.format(response.status_code))
    print('Send dialog result: {}'.format(response.text))


@app.route('/test2', methods=['POST', "GET"])
def test2():
    data_from_slash_command = request.form
    print("Data from slash command: ====> %s\n" % json.dumps(data_from_slash_command.to_dict(flat=False), indent=4, sort_keys=True))
    
    # do something that slash command want here
    # this task should be happend in background for avoid blocking slash command (max: 3s)
    # if more than 3s, it will lead to error
    send_dialog_to_slack_app___in_background(data_from_slash_command)

    return jsonify(text="hello ! this is repsonse from api server after get your test2 command. I'm doing what you want.."), 200    # this message will be show Only visible to you
    # return '', 200  # Don't show anything, just acknowledge response to confirm that api have received this command
    # Reference: https://api.slack.com/interactivity/slash-commands#responding_to_commands

# -----------------------------------------------------------------------------------



# @app.route('/interactivity', methods=['POST', "GET"])
# def slack_interactivity_handler():
#     """
#         this api is called when submit a dialog or view in slack app
#         or click a button, select menus...
#         See part: "Setup slack shared app interactivity" in readme.md
#     """
#     data_from_dialog_submition = request.form['payload']
#     data_from_dialog_submition = json.loads(data_from_dialog_submition)
#     print("Data from slack dialog submition ======> %s" % json.dumps(data_from_dialog_submition, indent=4, sort_keys=True))

#     handle_dialog_submition(data_from_dialog_submition)

#     return jsonify({}), 200     # NOTE: it must return empty body, 
#                                       # else error: We had some trouble connecting. Try again?
#                                       # and dialog will not closed


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8002, debug=True)