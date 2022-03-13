from bs4 import BeautifulSoup
import requests
import re

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
    nombre = nombre.replace("\"","")
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
            cap = cap[:cap.find(" ")]
            break
    for row in rows:
        if "Apertura" in row.get_text():
            aper = row.td.get_text()
            break
    cap = cap[cap.find("\n") + 1:]
    aper = aper[aper.find("\n") + 1:]
    return {"nombre":nombre,"capacidad":cap,"apertura":aper}

def cargarUrls(estadios):
    """
    Carga las urls de los estadios desde el fichero de datos de los equipos
    Devuelve una lista con las urls
    """
    urls = []
    f = open("dataEquipos.csv", "r", encoding="utf-8")
    for linea in f:
        campos = linea.split(";")
        campos[7] = campos[7].replace("\n","")
        campos[5] = campos[5].replace("\n","")
        if campos[7] not in urls:
            urls.append(campos[7])
            estadios.append(campos[5])
    f.close()
    return urls

def guardarDatos(urls,estadios):
    """
    Dada una lista de urls de estadios hace webscrapping y almacena los datos en dataEstadios.csv

    NOMBRE_ESTADIO;CAPACIDAD;FECHA_DE_APERTURA
    """
    f = open("dataEstadios.csv", "w", encoding="utf-8")
    contador = 0
    for urlEstadio in urls:
        try:
            datos = datosEstadio(urlEstadio)
            datos["apertura"] = re.sub('\s\s+',';',datos["apertura"])
            f.write(estadios[contador] + ";" + datos["capacidad"] + ";" + datos["apertura"] + "\n")
        except:
            print("Falla:",urlEstadio)
            f.write(estadios[contador] + ";" + "¿¿¿???" + ";" + "¿¿¿???" + "\n")
        contador += 1
    f.close()

estadios = []
urls = cargarUrls(estadios)
guardarDatos(urls,estadios)