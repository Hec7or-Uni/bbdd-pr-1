import pandas as pd

DATA_FOLDER = "data/"
SQL_FOLDER  = "sql/"
filename = "resultados"

df = pd.read_csv(DATA_FOLDER + filename + ".csv")

with open(SQL_FOLDER + filename + ".sql", "w", encoding="utf-8") as fd:
    prefijo = "INSERT INTO resultados (puntos, puesto, golesAF, golesEC, partidosGanados, partidosEmpatados, partidosPerdidos, asciende, desciende, europa, equipo, division, temporada, numJornada) values "

    for index, row in df.iterrows():
        values = "({}, {}, {}, {}, {}, {}, {}, {}, {}, {}, '{}', '{}', {}, {});".format(row["puntos"], row["puesto"], row["golesAF"],row["golesEC"],row["partidosGanados"],row["partidosEmpatados"],row["partidosPerdidos"],row["asciende"],row["desciende"],row["europa"],row["equipo"],row["division"],row["temporada"],row["numJornada"])
        fd.write(prefijo + values + "\n")