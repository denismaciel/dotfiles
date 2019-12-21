#! /usr/local/bin/python3

"""Small utility to display how many days I went to the Gym"""

from datetime import datetime, timedelta
import sqlite3
from pathlib import Path


def to_date(x):
    return datetime.strptime(x[:10], "%Y-%m-%d")


YEARS = 2
START_DATE = to_date("2019-12-01")
dates = [START_DATE + timedelta(i) for i in range(365 * YEARS)]

p = Path(__file__).parent
print(p)
conn = sqlite3.connect(p / "habits.sqlite")
cursor = conn.cursor()
trained = cursor.execute(
    """SELECT ts
    FROM records 
    LEFT JOIN habits 
      ON records.habit_id = habits.id 
    WHERE habit = 'Gym';"""
).fetchall()

trained = [to_date(i[0]) for i in trained]

month_name = {
    1: "Jan",
    2: "Feb",
    3: "Mar",
    4: "Apr",
    5: "May",
    6: "Jun",
    7: "Jul",
    8: "Aug",
    9: "Sep",
    10: "Oct",
    11: "Nov",
    12: "Dec",
}

d0 = dates[0]

output = [
    f""" 

                Year {d0.year} 
 {month_name.get(d0.month)} """
]

remaining = 0
for i, j in zip(dates, dates[1:]):
    if j.month != i.month:
        if j.year != i.year:
            output.append(
                f"""{' ' * (31 - remaining)}|

                Year {j.year} 
 {month_name.get(j.month)} """
            )
            output.append(f"")
        else:
            output.append(f"{' ' * (31 - remaining)}|\n {month_name.get(j.month)} ")
        remaining = 0

    if j in trained:
        output.append("*")
    else:
        output.append("_")

    remaining += 1

output.append(f"{' ' * (31 - remaining)}|")  # Add last delimiting |

print("".join(output))
