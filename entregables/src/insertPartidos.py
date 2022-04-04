import re
f = open("LigaHost.txt","r",encoding="utf-8")
fOut = open("poblate_partidos.sql","w",encoding="utf-8")
f.readline()
f.readline()
f.readline()
for linea in f:
    linea = linea[:linea.find("\n")]
    linea = re.sub('\s\s+',';',linea)
    campos = linea.split(";")
    temp = campos[0].split("-")
    fOut.write("INSERT INTO partidos (golesLocal, golesVisitante, local, visitante,division,temporada,numJornada) VALUES (")
    if len(campos) == 6:
        goles = campos[5].split("-")
        fOut.write(goles[0] + "," + goles[1] + ",\'" + campos[3] + "\',\'" + campos[4] + "\',")
        fOut.write("\'" + campos[1] + "\'," + temp[1] + "," + campos[2] + ");\n")
    else:
        goles = campos[4].split("-")
        casoFeo = 0
        fOut.write(goles[0] + "," + goles[1] + ",\'" + campos[2] + "\',\'" + campos[3] + "\',")
        fOut.write("\'" + campos[1] + "\'," + temp[1] + "," + str(casoFeo) + ");\n")

f.close()
fOut.close()