#!/usr/bin/env python3
import _thread as thread
import base64
import datetime
import hashlib
import hmac
import json
from urllib.parse import urlparse
import ssl
from datetime import datetime
from time import mktime
from urllib.parse import urlencode
from wsgiref.handlers import format_date_time
import argparse

import websocket  # 使用websocket_client
answer = ""


class WSParam(object):
    # 初始化
    def __init__(self, APPID, APIKey, APISecret, spark_url):
        self.APPID = APPID
        self.APIKey = APIKey
        self.APISecret = APISecret
        self.host = urlparse(spark_url).netloc
        self.path = urlparse(spark_url).path
        self.spark_url = spark_url

    # 生成url
    def create_url(self):
        # 生成RFC1123格式的时间戳
        now = datetime.now()
        date = format_date_time(mktime(now.timetuple()))

        # 拼接字符串
        signature_origin = "host: " + self.host + "\n"
        signature_origin += "date: " + date + "\n"
        signature_origin += "GET " + self.path + " HTTP/1.1"

        # 进行hmac-sha256进行加密
        signature_sha = hmac.new(self.APISecret.encode('utf-8'), signature_origin.encode('utf-8'),
                                 digestmod=hashlib.sha256).digest()

        signature_sha_base64 = base64.b64encode(
            signature_sha).decode(encoding='utf-8')

        authorization_origin = f'api_key="{self.APIKey}", algorithm="hmac-sha256", headers="host date request-line", signature="{signature_sha_base64}"'

        authorization = base64.b64encode(
            authorization_origin.encode('utf-8')).decode(encoding='utf-8')

        # 将请求的鉴权参数组合为字典
        v = {
            "authorization": authorization,
            "date": date,
            "host": self.host
        }
        # 拼接鉴权参数，生成url
        url = self.spark_url + '?' + urlencode(v)
        # 此处打印出建立连接时候的url,参考本demo的时候可取消上方打印的注释，比对相同参数时生成的url与自己代码生成的url是否一致
        return url


# 收到websocket错误的处理
def on_error(ws, error):
    print("### error:", error)


# 收到websocket关闭的处理
def on_close(ws, one, two):
    print(" ")


# 收到websocket连接建立的处理
def on_open(ws):
    thread.start_new_thread(run, (ws,))


def run(ws, *args):
    data = json.dumps(gen_params(
        appid=ws.appid,
        domain=ws.domain,
        messages=ws.messages,
        random_threshold=ws.random_threshold,
        max_tokens=ws.max_tokens))
    ws.send(data)


# 收到websocket消息的处理


def gen_params(appid, domain, random_threshold, max_tokens, messages):
    """
    通过appid和用户的提问来生成请参数
    """
    data = {
        "header": {
            "app_id": appid,
            "uid": "1234"
        },
        "parameter": {
            "chat": {
                "domain": domain,
                "random_threshold": random_threshold,
                "max_tokens": max_tokens,
                "auditing": "default"
            }
        },
        "payload": {
            "message": {
                "text": messages
            }
        }
    }
    return data


def Request(appid, secret, apikey, messages, version, random_threshold, max_token):
    if version == "v1":
        spark_url = "ws://spark-api.xf-yun.com/v1.1/chat"
        domain = "general"
    elif version == "v2":
        spark_url = "ws://spark-api.xf-yun.com/v2.1/chat"
        domain = "generalv2"
    ws_param = WSParam(appid, apikey, secret, spark_url)
    ws_url = ws_param.create_url()
    answer = ""

    def on_message(ws, message):
        data = json.loads(message)
        print(json.dumps(data, ensure_ascii=False))
        code = data['header']['code']
        if code != 0:
            ws.close()
        else:
            choices = data["payload"]["choices"]
            status = choices["status"]
            content = choices["text"][0]["content"]
            nonlocal answer
            answer += content
            if status == 2:
                ws.close()
    ws = websocket.WebSocketApp(
        ws_url, on_message=on_message, on_error=on_error, on_close=on_close, on_open=on_open)
    ws.appid = appid
    ws.messages = messages
    ws.domain = domain
    ws.random_threshold = random_threshold
    ws.max_tokens = max_token
    ws.run_forever(sslopt={"cert_reqs": ssl.CERT_NONE})


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("appid")
    parser.add_argument("secret")
    parser.add_argument("apikey")
    parser.add_argument("messages")
    parser.add_argument("--ver", "-v", default="v1")
    parser.add_argument("--random_threshold", "-r", default=0.5, type=float)
    parser.add_argument("--max_tokens", "-t", default=4096, type=int)
    parse_result = parser.parse_args()
    messages = json.loads(parse_result.messages)
    Request(parse_result.appid, parse_result.secret, parse_result.apikey, messages,
            parse_result.ver, parse_result.random_threshold, parse_result.max_tokens)


if __name__ == "__main__":
    main()
