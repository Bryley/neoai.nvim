#!/usr/bin/env python3
import requests
import json
import argparse
import sys


urls = {
    "ErnieBot": "https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/eb-instant",
    "ErnieBot-turbo": "https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/eb-instant",
}


def chat(api_key, secret_key, messages, m):
    url = urls[m] + "?access_token=" + get_access_token(api_key, secret_key)

    payload = json.dumps({
        "messages": messages
    })
    headers = {
        'Content-Type': 'application/json'
    }
    response = requests.request("POST", url, headers=headers, data=payload)
    print(response.text)


def get_access_token(api_key, secret_key):
    url = "https://aip.baidubce.com/oauth/2.0/token"
    params = {"grant_type": "client_credentials",
              "client_id": api_key, "client_secret": secret_key}
    return str(requests.post(url, params=params).json().get("access_token"))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('api_key')
    parser.add_argument('secret_key')
    parser.add_argument('messages')
    parser.add_argument('model')
    args = parser.parse_args()
    messages = json.loads(args.messages)
    chat(args.api_key, args.secret_key, messages, args.model)
