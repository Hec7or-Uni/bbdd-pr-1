import re
import csv
import pandas as pd

DATA_FOLDER = "data/"
CODE_FOLDER = "scripts/"
SQL_FOLDER  = "sql/"
ENTREGABLES_FOLDER  = "entregables/"

def trim(txt: str) -> str:
    """
    Pre:  Recibe una string <txt>
    Post: Devuelve un string resultante de sustituir todos los " " iniciales y 
          finales por la cadena vacia ("") y además, sustituye " " intermedios por " ".
    Ejem: string="    Hola    mundo    "
          return "Hola mundo"
    """
    x = re.sub("^\s+|\s+$", "", txt)
    x = re.sub("\s+", " ", x)
    return x

def getField(string: str, start, end) -> str:
    """
    Pre:  Recibe una string <string>
    Post: Recorta el string <string> desde <start> a <end> y le aplica la funcion trim(string)
    Ejem: string="1972-1973    1ª       1     Granada          Zaragoza         0-0"
          start = 0
          end   = 10
          return "1972-1973"
    """
    try:
        if type(start) == None:
            return trim(string[:end])
        elif type(end) == None:
            return trim(string[start:])
        else:
            # Avisa de que hay datos que estan vacios
            if trim(string[start:end]).isspace(): print("Se ha detectado un dato vacio")
            return trim(string[start:end])
    except Exception as e:
        print(e)

def txt2tables(filename) -> None:
    """
    Pre:  Recibe un fichero de texto sin extension <filename>
          <filename> tiene que ser un txt
    Post: Crea con la información de <filename> un fichero .csv y otro .xlsx
          ordenados por [TEMPORADA, DIVISION, JORNADA]
    """
    try:
        # reading TXT
        with open(DATA_FOLDER + filename + ".txt", "r", encoding="utf-8") as fd:
            lines = fd.readlines()
            lista = []
            for line in lines[3:]:
                temporada = getField(line, start=0, end=10)
                division  = getField(line, start=10, end=21)
                jornada   = getField(line, start=21, end=28)
                local     = getField(line, start=28, end=45)
                visitante = getField(line, start=45, end=61)
                golesL, golesV  = getField(line, start=61, end=None).split("-")
                row = [temporada, division, jornada, local,visitante, golesL, golesV]
                lista.append(row)

        # writting CSV - AUXILIAR
        # Este csv sera sobreescrito por la informacion correcta en el siguiente paso
        with open(DATA_FOLDER + filename + ".csv", "w", encoding="utf-8", newline="") as fd:
            writer = csv.writer(fd)
            writer.writerow(["TEMPORADA","DIVISION","JORNADA","LOCAL","VISITANTE","GL","GV"])
            writer.writerows(lista)

        # Gnera el CSV & Excel con la informacion ordenada
        def sortEnd(filename: str, filter: list) -> None:
            """
            Pre:  Recibe un fichero de texto sin extension <filename>
                  <filename> tiene que ser un csv
            Post: Carga el fichero <filename>.csv en un dataframe de pandas y genera los 
                  archivos (csv y excel) con los datos ordenados por: TEMPORADA, DIVISION, JORNADA
            """
            df = pd.read_csv(DATA_FOLDER + filename + ".csv")
            df.sort_values(by=filter, ascending=False)
            print(df.info())
            df.to_csv(DATA_FOLDER + filename + ".csv", index=False, encoding="utf-8")
            df.to_excel(DATA_FOLDER + filename + ".xlsx", index=False, encoding="utf-8")

        sortEnd(filename, filter= ["TEMPORADA","DIVISION","JORNADA"])
    except Exception as e:
        print(e)


def main() -> None: 
    txt2tables("LigaHost")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(e)
