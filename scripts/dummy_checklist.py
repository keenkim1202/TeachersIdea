from datetime import timedelta, date
import json
import random
import uuid


JSON = "checklist_3.json"
SCORE_HIGH = "우수"
SCORE_MID = "보통"
SCORE_LOW = "미흡"


def rand_score():
    num = random.randint(1, 3)
    if num == 1:
        return SCORE_HIGH
    elif num == 2:
        return SCORE_MID
    else:
        return SCORE_LOW


def rand_checklist():
    with open(JSON, encoding="UTF-8") as fp:
        data = json.load(fp=fp)
        for section in data:
            for sub in section["subtitles"]:
                for body in sub["body"]:
                    body["score"] = rand_score()
        return data


if __name__ == '__main__':
    start = date(2020, 8, 1)
    end = date(2020, 9, 30)
    delta = timedelta(days=1)
    result = []
    while start <= end:
        data = rand_checklist()
        report = {
            "id": str(uuid.uuid4()),
            "checklist": data,
            "date": start.strftime("%Y-%m-%d")
        }
        result.append(report)
        start += delta

    with open("dummy_checklist.json", "w", encoding="UTF-8") as fp:
        json.dump(result, fp, ensure_ascii=False, indent=4, sort_keys=True)
