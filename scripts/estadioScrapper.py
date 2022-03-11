from bs4 import BeautifulSoup
import requests

# def buscarUrlEstadio(urlEquipo):
#     """
#     Dada la url de un equipo en la wikipedia, devuelve la url en wikipedia correspondiente
#     al estadio de dicho equipo
#     """
#     html = requests.get(urlEquipo).text
#     soup = BeautifulSoup(html, 'html.parser')
#     table = soup.table
#     rows = table.find_all("tr")
#     for row in rows:
#         if "Estadio" in row.get_text():
#             links = row.a
#             link = links.get("href")
#             return "https://es.wikipedia.org" + link

def datosEstadio(urlEstadio):
    """
    Dada la url de un estadio devuelve un diccionario con los siguientes campos
    
    nombre
    capacidad
    apertura

    Dichos campos son strings a excepción de capacidad que es un entero
    """
    html = requests.get(urlEstadio).text
    soup = BeautifulSoup(html, 'html.parser')
    nombre = soup.h1.get_text()
    table = soup.table
    rows = table.find_all("tr")
    for row in rows:
        if "Capacidad" in row.get_text():
            cap = row.td.get_text()
            cap = cap.replace(" ", "")
            cap = cap.replace(" ", "")
            cap = cap.replace(".", "")
            cap = cap[:cap.find("[")]
            cap = cap[:cap.find("e")]
            break
    for row in rows:
        if "Apertura" in row.get_text():
            aper = row.td.get_text()
            break
    cap = cap[cap.find("\n") + 1:]
    aper = aper[aper.find("\n") + 1:]
    return {"nombre":nombre,"capacidad":cap,"apertura":aper}

def cargarUrls():
    """
    Carga las urls de los estadios desde el fichero de datos de los equipos
    Devuelve una lista con las urls
    """
    urls = []
    f = open("dataEquipos.csv", "r", encoding="utf-8")
    for linea in f:
        campos = linea.split(";")
        campos[7] = campos[7].replace("\n","")
        if campos[7] not in urls:
            urls.append(campos[7])
    f.close()
    return urls

def guardarDatos(urls):
    """
    Dada una lista de urls de estadios hace webscrapping y almacena los datos en dataEstadios.csv

    NOMBRE_ESTADIO;CAPACIDAD;FECHA_DE_APERTURA
    """
    f = open("dataEstadios.csv", "w", encoding="utf-8")
    for urlEstadio in urls:
        try:
            datos = datosEstadio(urlEstadio)
            f.write(datos["nombre"] + ";" + datos["capacidad"] + ";" + datos["apertura"] + "\n")
        except:
            print("Falla:",urlEstadio)
            f.write("¿¿¿???" + ";" + "¿¿¿???" + ";" + "¿¿¿???" + "\n")
    f.close()

def main():
    urls = cargarUrls()
    guardarDatos(urls)

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(e)


