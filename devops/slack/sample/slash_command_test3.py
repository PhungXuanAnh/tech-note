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
def send_view_to_slack_app___in_background(data):
    """
        This method define how a view is show in slack app
        NOTE: check meaning of error message of this api here: https://api.slack.com/methods/views.open#errors
    """
    response = requests.post(
        url="https://slack.com/api/views.open",
        headers={
            'Content-Type': 'application/json',
            "Authorization": "Bearer " + APP_TOKEN
        },
        json={
            'trigger_id': data.get('trigger_id'),
            'view': {
                "type": "modal",
                "title": {
                    "type": "plain_text",
                    "text": "This is test view title"
                },
                "blocks": [
                    {
                        "type": "section",
                        "text": {
                            "type": "mrkdwn",
                            "text": "markdown: It's Block Kit...but _in a modal_"
                        },
                        "block_id": "button_block_id_1",
                        "accessory": {
                            "type": "button",
                            "text": {
                            "type": "plain_text",
                            "text": "Click me"
                            },
                            "action_id": "button_action_id_1",
                            "value": "Button value",
                            "style": "danger"
                        }
                    },
                    {
                        "block_id": "plain_text_input_block_id_1",
                        "type": "input",
                        "label": {
                            "type": "plain_text",
                            "text": "Number input"
                        },
                        "element": {
                            "type": "plain_text_input",
                            "action_id": "plain_text_input_action_id_1",
                            "placeholder": {
                                "type": "plain_text",
                                "text": "Bat buoc phai nhap vao, va phai nhap so"
                            },
                            "multiline": False
                        },
                        "optional": True
                    },
                    {
                        "block_id": "plain_text_input_block_id_3",
                        "type": "input",
                        "label": {
                            "type": "plain_text",
                            "text": "Nhap bat cu cai gi"
                        },
                        "element": {
                            "type": "plain_text_input",
                            "action_id": "plain_text_input_action_id_3",
                            "placeholder": {
                                "type": "plain_text",
                                "text": "muc nay bat buoc phai nhap, vi tuy chon optional: False"
                            },
                            "multiline": False
                        },
                        "optional": False
                    },
                    {
                        "block_id": "plain_text_input_block_id_2",
                        "type": "input",
                        "label": {
                            "type": "plain_text",
                            "text": "Multiple line"
                        },
                        "element": {
                            "type": "plain_text_input",
                            "action_id": "plain_text_input_action_id_2",
                            "placeholder": {
                            "type": "plain_text",
                            "text": "De tao cai nay set: multiline: True ben duoi \n muc nay la tuy chon vi optional: true"
                            },
                            "multiline": True # Refer: https://api.slack.com/reference/block-kit/block-elements#input
                        },
                        "optional": True
                    },
                    {
                        "block_id": "datepicker_block_id_1",
                        "type": "section",
                        "text": {
                            "type": "mrkdwn",
                            "text": "Pick a date for the deadline."
                        },
                        "accessory": {
                            "type": "datepicker",
                            "initial_date": "2021-04-21",
                            "placeholder": {
                                "type": "plain_text",
                                "text": "Select a date",
                                "emoji": True
                            },
                            "action_id": "datepicker_action_id_1"
                        }
                    },
                    {
                        "block_id": "radio_buttons_inside_input_block_id_3",
                        "type": "input",
                        "label": {
                            "type": "plain_text",
                            "text": "Radio buttons inside Input block for avoid block_action request"
                        },
                        "element": {
                            "type": "radio_buttons",
                            "action_id": "this_is_an_action_id",
                            "initial_option": {
                            "value": "A1",
                            "text": {
                                "type": "plain_text",
                                "text": "Radio 1"
                            }
                            },
                            "options": [
                            {
                                "value": "A1",
                                "text": {
                                "type": "plain_text",
                                "text": "Radio 1"
                                }
                            },
                            {
                                "value": "A2",
                                "text": {
                                "type": "plain_text",
                                "text": "Radio 2"
                                }
                            }
                            ]
                        },
                        "optional": False
                    },
                    {
                        "block_id": "radio_buttons_block_id_1",
                        "type": "section",
                        "text": {
                            "type": "mrkdwn",
                            "text": "Radio buttons inside session block with cause a block_action request when change it"
                        },
                        "accessory": {
                            "type": "radio_buttons",
                            "initial_option": {
                                "value": "value 1111111111111111111111111111",
                                "text": {
                                    "type": "plain_text",
                                    "text": "text 1"
                                }
                            },
                            "options": [
                                {
                                    "text": {
                                        "type": "plain_text",
                                        "text": "text 1",
                                        "emoji": True
                                    },
                                    "value": "value 1111111111111111111111111111"
                                },
                                {
                                    "text": {
                                        "type": "plain_text",
                                        "text": "text 2",
                                        "emoji": True
                                    },
                                    "value": "value 222222222222222222222222222222"
                                }
                            ],
                            "action_id": "radio_buttons_action_id_1",
                        }
                    },
                    {
                        "type": "section",
                        "block_id": "static_select_block_id_1",
                        "text": {
                        "type": "mrkdwn",
                        "text": "Pick an item from the dropdown list"
                        },
                        "accessory": {
                        "action_id": "static_select_action_id_1",
                        "type": "static_select",
                        "placeholder": {
                            "type": "plain_text",
                            "text": "Select an item"
                        },
                        "options": [
                            {
                                "text": {
                                    "type": "plain_text",
                                    "text": "item 1"
                                },
                                "value": "item 1111111111111111111111111"
                            },
                            {
                                "text": {
                                    "type": "plain_text",
                                    "text": "item 2"
                                },
                                "value": "item 22222222222222222222222222222"
                            }
                        ]
                        }
                    }
                ],
                "close": {
                    "type": "plain_text",
                    "text": "Cancel"
                },
                "submit": {
                    "type": "plain_text",
                    "text": "Save"
                },
                "private_metadata": data.get('response_url'),
                "callback_id": "view_identifier_12",
            }
        }
    )
    print('Send view status_code: {}'.format(response.status_code))
    print('Send view result: {}'.format(response.text))


@app.route('/test3', methods=['POST', "GET"])
def test3():
    data_from_slash_command = request.form
    print("Data from slash command: ====> %s\n" % json.dumps(data_from_slash_command.to_dict(flat=False), indent=4, sort_keys=True))
    
    check_is_request_from_slack(request.form)

    # do something that slash command want here
    # this task should be happend in background for avoid blocking slash command (max: 3s)
    # if more than 3s, it will lead to error
    send_view_to_slack_app___in_background(data_from_slash_command)

    return jsonify({'msg': "hello ! this is repsonse from api server after get your test3 command. I'm doing what you want.."}), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3333, debug=True)
