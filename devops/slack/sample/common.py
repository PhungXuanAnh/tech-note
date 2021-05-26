from flask import Flask, jsonify, abort, make_response, request, url_for
import requests
import json
# from zappa.asynchronous import task   # create background task using zappa, when deploy with aws lambda

with open("/home/xuananh/Dropbox/Work/Other/credentials_bk/slack_phungxuananh_workspace.json", 'r') as f:
    slack_info = json.load(f)
    APP_TOKEN = slack_info["apps"]["test-app1"]["Bot User OAuth Token"]
    SLACK_VERIFICATION_TOKEN = slack_info["apps"]["test-app1"]["Verification Token"]
    SLACK_TEAM_ID = slack_info["team_id"]


def check_is_request_from_slack(data):
    slack_verify_token = data['token']
    team_id = data.get('team_id')   # this request from slash command
    if not team_id: team_id = data['team']['id']    # this request from submit dialog for view

    print("\nSlack verify token: %s" % slack_verify_token)
    print("Slack team id: %s\n" % team_id)

    if slack_verify_token != SLACK_VERIFICATION_TOKEN or team_id != SLACK_TEAM_ID:
        abort(400, description="This request is not from slack !")



# @task
def handle_dialog_submition(data_from_dialog_submition):
    """
        This method handle data from dialog submit, for example save data to 3th service
        then send result back to slack channel where this command is invoked
            
        NOTE: this task should be happend in background for avoid blocking dialog (max: 3s)
        if more than 3s, it will lead to error
    """
    submited_data = data_from_dialog_submition['submission']
    # result_after_handler_submition = call_3th_service(data_from_dialog_submition)

    channel_url = data_from_dialog_submition.get('response_url')
    return_str = {
        "response_type": "in_channel",
        "text": "You have submited data:\n text_input: %s \n select_box: %s \n text_area: %s" % (submited_data['text_input'], submited_data['select_box'], submited_data['textarea_input'])
    }
    response = requests.post(
        url=channel_url,
        headers={'Content-Type': 'application/json'},
        json=return_str
    )
    print("Send result after handler submition status_code %s" % response.status_code)
    print("Send result after handler submition text %s" % response.text)


# @task
def handle_view_submition(data_interactivity):
    """
        This method handle data from view submit, for example save data to 3th service
        then send result back to slack channel where this command is invoked
            
        NOTE: this task should be happend in background for avoid blocking view (max: 3s)
        if more than 3s, it will lead to error
    """
    if "actions" in data_interactivity:
        # NOTE: when change data of some fields in slack model, for ex select box or radio button or date_picker
        # slack also send request to `interactivity` endpoint, this is call block_action request
        # and there is one more field name `actions: []` in the body of that request
        # so, we check if this field is exist, then ignore this action, 
        # here we only handle quest when click button submit
        # or you can handle action request base yourself here
        # 
        # NOTE: If you don't want slack send block_actions payloads, then define element inside input block
        # see example: "block_id": "radio_buttons_inside_input_block_id_3" at test3 command
        # and see block_actions payloads detail here: https://api.slack.com/reference/interaction-payloads/block-actions
        print("Ignore action with action: %s" % json.dumps(data_interactivity['actions'], indent=4, sort_keys=True))
        return

    submited_data = data_interactivity['view']['state']["values"]
    # result_after_handler_submition = call_3th_service(data_interactivity)

    channel_url = data_interactivity['view']["private_metadata"]
    return_str = {
        "response_type": "in_channel",
        "text": "You have submited data:\n datepicker_1: %s \n plain_text_input_1: %s \n radio_buttons_1: %s \n static_select_1: %s" % 
            (submited_data['datepicker_block_id_1']["datepicker_action_id_1"]["selected_date"], 
            submited_data['plain_text_input_block_id_1']["plain_text_input_action_id_1"]["value"],
            submited_data['radio_buttons_block_id_1']['radio_buttons_action_id_1']["selected_option"]["value"],
            submited_data['static_select_block_id_1']['static_select_action_id_1']["selected_option"]["value"])
    }
    response = requests.post(
        url=channel_url,
        headers={'Content-Type': 'application/json'},
        json=return_str
    )
    print("Send result after handler submition status_code %s" % response.status_code)
    print("Send result after handler submition text %s" % response.text)


def validate_submited_data(data_interactivity):
    error_msg = None
    submited_data = data_interactivity['view']['state']["values"]
    text_input = submited_data['plain_text_input_block_id_1']["plain_text_input_action_id_1"]["value"]
    if not text_input:
        error_msg = "Khong duoc rong."
    else:
        try:
            int(text_input)
        except Exception:
            error_msg = "Chi duoc nhap so."

    print("Validate input result: %s" % error_msg)

    if error_msg:
        return {
            "response_action": "errors",
            "errors": {
                "plain_text_input_block_id_1": error_msg   # NOTE: key phai la block id cua cai truong dang kiem tra
                                                            # refer: https://api.slack.com/surfaces/modals/using#displaying_errors
            }
        }
    else:
        return None


# @app.route('/interactivity', methods=['POST', "GET"])
def slack_interactivity_handler():
    """
        this api is called when submit a view or view in slack app
        or click a button, select menus...
        See part: "Setup slack shared app interactivity" in readme.md
        NOTE: this api is using for all submition in this slack share app
    """

    data_interactivity = request.form['payload']
    data_interactivity = json.loads(data_interactivity)
    print("Data from slack interactivity  ======> %s" % json.dumps(data_interactivity, indent=4, sort_keys=True))

    check_is_request_from_slack(data_interactivity)

    print("Data interactivity type: %s " % data_interactivity['type'])

    if data_interactivity['type'] == 'view_submission':
        result = validate_submited_data(data_interactivity)
        if result: return result, 200

        handle_view_submition(data_interactivity)

    if data_interactivity['type'] == 'dialog_submission':
        handle_dialog_submition(data_interactivity)

    return jsonify({}), 200     # NOTE: this api must return empty body, 
                                # else error: We had some trouble connecting. Try again?
                                # and view will not closed