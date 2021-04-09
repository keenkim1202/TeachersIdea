# This is a sample Python script.

# Press ⌃R to execute it or replace it with your code.
# Press Double ⇧ to search everywhere for classes, files, tool windows, actions, and settings.

from korean_name_generator import namer
from datetime import timedelta, date, datetime
import uuid
import json
import random
import requests


JSON = "checklist_3.json"
SCORE_HIGH = "우수"
SCORE_MID = "보통"
SCORE_LOW = "미흡"


def rand_weight():
    num = random.uniform(2.5, 22.85)
    return round(num, 2)


def rand_height():
    num = random.uniform(49.35, 119.54)
    return round(num, 2)


def rand_phn():
    n = '0000000000'
    while '9' in n[3:6] or n[3:6]=='000' or n[6]==n[7]==n[8]==n[9]:
        n = str(random.randint(10**9, 10**10-1))
    return n[:3] + '-' + n[3:6] + '-' + n[6:]


def rand_date():
    year = random.randint(16, 20)
    month = random.randint(1, 12)
    if month == 2:
        day = random.randint(1, 28)
    elif month in (1, 3, 5, 7, 8, 10, 12):
        day = random.randint(1, 31)
    else:
        day = random.randint(1, 30)
    str = f"20{year}-{month}-{day}"
    date = datetime.strptime(str, '%Y-%m-%d')
    return date.strftime("%Y-%m-%d")


def rand_score():
    num = random.randint(1, 3)
    if num == 1:
        return SCORE_HIGH
    elif num == 2:
        return SCORE_MID
    else:
        return SCORE_LOW


def rand_image():
    res = requests.get("https://picsum.photos/200/300")
    return res.url


def rand_checklist():
    with open(JSON, encoding="UTF-8") as fp:
        data = json.load(fp=fp)
        for section in data:
            for sub in section["subtitles"]:
                for body in sub["body"]:
                    body["score"] = rand_score()
        return data


def make_dummy_checklist(arr, child):
    start = date(2020, 9, 1)
    end = date(2020, 9, 29)
    delta = timedelta(days=1)
    while start <= end:
        if start.weekday() > 4:
            start += delta
            continue
        data = rand_checklist()
        report = {
            "id": str(uuid.uuid4()),
            "child": child,
            "checklist": data,
            "date": start.strftime("%Y-%m-%d")
        }
        arr.append(report)
        start += delta


def make_dummy_child(group, count):
    children = []
    data = []
    for i in range(count):
        child = {
            "id": str(uuid.uuid4()),
            "name": namer.generate(i % 2 == 0),
            "group": group,
            "birthday": rand_date(),
            "comment": "",
            "height": rand_height(),
            "weight": rand_weight(),
            "momPhone": rand_phn(),
            "dadPhone": rand_phn(),
            "photoUrl": rand_image()
        }
        make_dummy_checklist(data, child["id"])
        children.append(child)
    return children, data


if __name__ == '__main__':
    COUNT = 30
    dummy = [
        make_dummy_child("햇님반", COUNT),
        make_dummy_child("달님반", COUNT),
        make_dummy_child("별님반", COUNT)
    ]
    rst_child = []
    rst_checklist = []
    for i, j in dummy:
        rst_child.extend(i)
        rst_checklist.extend(j)

    with open("dummy_child.json", "w", encoding="UTF-8") as fp:
        json.dump(rst_child, fp, ensure_ascii=False, indent=4, sort_keys=True)

    with open("dummy_checklist.json", "w", encoding="UTF-8") as fp:
        json.dump(rst_checklist, fp, ensure_ascii=False, indent=4, sort_keys=True)

