from bs4 import BeautifulSoup
import requests

def buscarUrlEstadio(urlEquipo):
    """
    Dada la url de un equipo en la wikipedia, devuelve la url en wikipedia correspondiente
    al estadio de dicho equipo
    """
    html = requests.get(urlEquipo).text
    soup = BeautifulSoup(html, 'html.parser')
    table = soup.table
    rows = table.find_all("tr")
    for row in rows:
        if "Estadio" in row.get_text():
            links = row.a
            link = links.get("href")
            return "https://es.wikipedia.org" + link

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
            cap = cap[:cap.find("e") - 1]
            break
    for row in rows:
        if "Apertura" in row.get_text():
            aper = row.td.get_text()
            break
    cap = cap[cap.find("\n") + 1:]
    cap = int(cap)
    aper = aper[aper.find("\n") + 1:]
    return {"nombre":nombre,"capacidad":cap,"apertura":aper}

urlEquipo = "https://es.wikipedia.org/wiki/Real_Zaragoza"
urlEstadio = buscarUrlEstadio(urlEquipo)
datos = datosEstadio(urlEstadio)
print(datos["nombre"])
print(datos["capacidad"])
print(datos["apertura"])