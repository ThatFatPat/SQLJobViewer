from flask import Flask, render_template, request
import logging
from logging import FileHandler
import pyodbc as sql
import hashlib
import json

app = Flask(__name__)

logger = FileHandler('./error.log')
logger.setFormatter(logging.Formatter('[%(asctime)s] %(levelname)s in %(module)s: %(message)s'))
app.logger.setLevel(logging.DEBUG)
app.logger.addHandler(logger)

try:
    settings = None
    with open('./settings.json') as settings_file:
        settings = json.loads(settings_file.read())
except Exception as e:
    app.logger.error("ERROR While reading and parsing settings.json: {}".format(str(e)))


# Note: Name will be added first by default! This is to allow matching extended_properties to items. 
# This should probably be done using id, but I did not have the ability to implement this at the time of writing.


def getItemsFromSQL():
    ret = []
    for i, database in enumerate(settings["databases"]):
        try:
            conn = sql.connect(database, timeout=settings["timeout"])
        except Exception as e:
            app.logger.error("ERROR While connecting to databases[{}]: {}".format(i, str(e)))
            continue
        cursor = conn.cursor()

        cursor.execute(settings['query'])

        rows = cursor.fetchall()
        if rows[0] is not None:
            cols = [t[0] for t in rows[0].cursor_description]
            if ret == []:
                ret.extend([cols])
            dict_rows = [dict(zip(cols, list(row))) for row in rows]
            ret.extend(dict_rows)
        conn.close()
    return ret

@app.route('/')
def displayTable():
    items = getItemsFromSQL()
    if items == []:
        return render_template('index.html')
    return render_template('index.html', items = items[1:], columns = items[0])
