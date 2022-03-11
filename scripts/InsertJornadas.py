import pandas as pd
import csv

def insert(tableName: str, keyNames: list, valNames: list) -> str:
    """
    INSERT INTO tableName (column1, column2, ...) VALUES (value1, value2, ...);
    """
    try:
        keyNames = str(keyNames).replace("[", "(").replace("]", ")")
        valNames = str(valNames).replace("[", "(").replace("]", ")")
        return f"INSERT INTO {tableName} {keyNames} VALUES {valNames}"
    except Exception as err:
        print(err)

df = pd.read_csv("LigaHost.csv")
df.drop(['LOCAL', 'VISITANTE', 'GL', 'GV'], axis = 'columns', inplace=True)

list_df = df.values.tolist()

sample_set = set() # defining set
#using for loop
t = {str(x)[1:-1] for x in list_df}

t = list(t)

t = [x.replace("\'", "")[5:].split(", ") for x in t]


with open("inserts_jornadas.sql", "w", encoding="utf-8") as fd:
    for x in t:
        cadena = f"INSERT INTO jornadas (division, temporada, numJornada) VALUES ('{x[1]}', {x[0]}, {x[2]});"
        fd.write(cadena + "\n")