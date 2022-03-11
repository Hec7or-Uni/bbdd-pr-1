"""
script de generacion del fichero sql para la poblacion de la tabla jornadas
"""
import pandas as pd
import csv

DATA_FOLDER = "data/"
SQL_FOLDER  = "sql/"

def main():
    # Lectura de los datos
    df = pd.read_csv(DATA_FOLDER + "LigaHost.csv")
    df.drop(['LOCAL', 'VISITANTE', 'GL', 'GV'], axis = 'columns', inplace=True)
    list_df = df.values.tolist()

    # Eliminamos tuplas repetidas del formato: [Temporada, Division, Jornada]
    t = {str(x)[1:-1] for x in list_df} 
    t = list(t)

    # Escritura de datos: lista -> sql
    t = [x.replace("\'", "")[5:].split(", ") for x in t]
    with open(SQL_FOLDER + "inserts_jornadas.sql", "w", encoding="utf-8") as fd:
        for x in t:
            cadena = f"INSERT INTO jornadas (division, temporada, numJornada) VALUES ('{x[1]}', {x[0]}, {x[2]});"
            fd.write(cadena + "\n")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(e)


