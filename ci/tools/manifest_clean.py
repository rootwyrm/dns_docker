#!/usr/bin/env python3

import sys, os
from argparse import ArgumentParser
import requests
import json

def hub_login(args):
    print("Logging in to hub.docker.com... ", end='')
    headers = {
        'User-Agent': 'rootwyrm/rootcore/ci/tools/docker_hub',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    }
    login_url = "https://hub.docker.com/v2/users/login"
    login_data = json.JSONEncoder().encode({"username":args.username,"password":args.password})
    response = requests.post(login_url, headers=headers, data=login_data)
    if response.status_code != 200:
        print("ERROR %s" % response.status_code)
    else:
        print("OK")
    raw_token = response.json()
    result = raw_token['token']
    return(result)

def hub_logout(token):
    ## This is a very simple one, we only provide the User-Agent to make it easier
    ## on hub if we need to troubleshoot.
    print("Logging out of hub.docker.com... ", end='')
    headers = {
        'User-Agent': 'rootwyrm/rootcore/ci/tools/docker_hub',
        'Accept': 'application/json',
        'Authorization': f'JWT {token}',
    }
    logout_url = "https://hub.docker.com/v2/logout"
    response = requests.post(logout_url, headers=headers, data='')
    if response.status_code == 200:
        print("OK")
    else:
        print("ERROR %s" % response.status_code)
        sys.exit(2)    

def hub_tag_delete(args,token):
    ## Define our endpoint at the top.
    headers = {
        'User-Agent': 'rootwyrm/rootcore/ci/tools/docker_hub',
        'Accept': 'application/json',
        'Authorization': f'JWT {token}',
    }
    ## respositories/$user/$container/tags/$tag
    url_base = f"https://hub.docker.com/v2/repositories/{args.username}/{args.container}/tags"
    print("Operating on repository %s" % args.container)
    ## Try it as a file first.
    try:
        open(args.tags, "r")
        tagfile = open(args.tags)
        for tag in list(tagfile):
            target = f"{url_base}/{tag}".strip('\n')
            delete = requests.delete(target, data='', headers=headers)
            result = delete.status_code
            list = [container, ':', tags]
            print("".join(list), "- ", end='')
            hub_return_check(result)
    ## Working with a bare tag argument.
    except IOError:
        target = f"{url_base}/{args.tags}".strip('\n')
        delete = requests.delete(target, data='', headers=headers)
        result = delete.status_code
        container = args.container
        tags = args.tags
        list = [container, ':', tags]
        print("".join(list), "- ", end='')
        hub_return_check(result)
    except:
        print("Encountered an unknown error.")
        sys.exit(1)

def hub_return_check(result):
    if result == 204:
        print("deleted.")
    elif result == 202:
        print("queued.")
    elif result == 404:
        print("not found.")
    elif result == 403:
        print("returned unauthorized!")
        ## Need some debug.
        print(delete.text)
        print(delete.body)
    elif result == 401:
        print("authorization token failure!")
        sys.exit(10)
    else:
        print("error - %s" % result)

def main():
    parser = ArgumentParser(description="Cleans up Docker Hub tags")
    parser.add_argument("-u", "--user", dest="username", type=str, help="<username>", required=True)
    parser.add_argument("-p", "--pass", dest="password", type=str, help="<password>", required=True)
    parser.add_argument("-c", "--cont", dest="container", type=str, help="<container>", required=True)
    parser.add_argument("-t", "--tags", dest="tags", type=str, help="<tag.file>", required=True)
    args = parser.parse_args()
    token = hub_login(args)
    hub_tag_delete(args,token)
    hub_logout(token)

main()
