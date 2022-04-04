f = open("dataEquipos.csv","r",encoding="utf-8")
fOut = open("poblate_teams.sql","w",encoding="utf-8")
for linea in f:
    linea = linea[:linea.find("\n")]
    campos = linea.split(";")
    
    fOut.write("INSERT INTO equipos (nombreCorto, nombreOficial, nombreHistorico , ciudad , fechaFundacion , estadio) VALUES (")
    fOut.write("\'" + campos[0] + "\',\'" + campos[1] + "\',\'" + campos[2] + "\', \'" + campos[3] + "\'")
    fOut.write(","+ campos[4] + ",\'" + campos[5] + "\');\n")
f.close()
f = open("dataEqManual.csv","r",encoding="utf-8")
for linea in f:
    linea = linea[:linea.find("\n")]
    campos = linea.split(";")
    
    fOut.write("INSERT INTO equipos (nombreCorto, nombreOficial, nombreHistorico , ciudad , fechaFundacion , estadio) VALUES (")
    fOut.write("\'" + campos[0] + "\',\'" + campos[1] + "\',\'" + campos[2] + "\', \'" + campos[3] + "\'")
    fOut.write(","+ campos[4] + ",\'" + campos[5] + "\');\n")
f.close()

fOut.close()