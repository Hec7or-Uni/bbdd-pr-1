from bs4 import BeautifulSoup
import requests
import re

def listarEquipos():
    """
    Devuelve una lista que contiene los nombres de todos los equipos
    """
    f = open("LigaHost.txt", 'r' , encoding="utf-8")
    f.readline()
    f.readline()
    f.readline()
    equipos = []
    for linea in f:
        linea = re.sub('\s\s+',';',linea)
        campos = linea.split(";")
        if len(campos) == 5 and campos[2] not in equipos:
            equipos.append(campos[2])
        if campos[3] not in equipos:
            equipos.append(campos[3])
        if len(campos) == 6 and campos[4] not in equipos:
            equipos.append(campos[4])
    f.close()
    return equipos

def escribirEquipos(equipos):
    """
    Dada una lista de equipos la escribe en formato .txt teniendo en cada linea un equipo
    """
    f = open("ListaEquipos.txt","w",encoding="utf-8")
    for equipo in equipos:
        f.write(equipo + "\n")
    f.close()

def obtenerInformacion(equipos):
    """
    Dada una lista de equipos obtiene la información de todos ellos de wikipedia y la guarda en un 
    csv que sigue el siguiente formato

    NOMBRE_CORTO;NOMBRE;NOMBRE_HISTORICO;CIUDAD;FECHA_FUNDACION;ESTADIO;ENLACE_EQUIPO;ENLACE_ESTADIO
    """
    url = "https://es.wikipedia.org/wiki/Anexo:Evoluci%C3%B3n_de_los_clubes_de_f%C3%BAtbol_en_Espa%C3%B1a"
    html = requests.get(url).text
    soup = BeautifulSoup(html, 'html.parser')
    table = soup.table
    rows = table.find_all("tr")
    f = open("dataEquipos.csv" , "w" , encoding="utf-8")
    for EQUIPO in equipos:
        first = True
        for row in rows:
            if not first:
                colums = row.find_all("td")
                nombre = colums[0].get_text()
                ciudad = colums[1].get_text()
                fecha = colums[2].get_text()
                if len(colums) == 7:
                    nombreHistorico = colums[4].get_text()
                    estadio = colums[5].get_text()
                    enlEst = colums[5].a
                else:
                    nombreHistorico = colums[3].get_text()
                    estadio = colums[4].get_text()
                    enlEst = colums[4].a
                enlaceEquipo = colums[0].find_all("a")
                enlaceEquipo = "https://es.wikipedia.org" + enlaceEquipo[1].get("href")
                try:
                    enlaceEstadio = "https://es.wikipedia.org" + enlEst.get("href")
                except:
                    enlaceEquipo = ""
                nombre = nombre.replace("\n","")
                ciudad = ciudad.replace("\n","")
                fecha = fecha.replace("\n","")
                nombreHistorico = nombreHistorico.replace("\n","")
                estadio = estadio.replace("\n","")
                enlaceEquipo = enlaceEquipo.replace("\n","")
                enlaceEstadio = enlaceEstadio.replace("\n","")
                auxiliar = True
                for el in EQUIPO.split():
                    el = el[:el.find(".") - 1]
                    auxiliar = auxiliar and (el in nombre or el in nombreHistorico or el in ciudad)
                if auxiliar:
                    break
            else:
                first = False
        f.write(EQUIPO + ";" + nombre + ";" + nombreHistorico + ";" + ciudad + ";" + fecha + ";" + estadio + ";" + enlaceEquipo + ";" + enlaceEstadio + "\n")
    f.close()    

equipos = listarEquipos()
escribirEquipos(equipos)
obtenerInformacion(equipos)
