#Nuevo Estadio de Los Cármenes;1943;16 de mayo de 1995
#INSERT INTO estadios ("nombre", "capacidad", "fechaInauguracion")
#VALUES ("Nuevo Estadio de Los Cármenes", 1943, "16 de mayo de 1995");
f = open("dataEstadios.csv","r",encoding="utf-8")
fOut = open("poblate_stadiums.sql","w",encoding="utf-8")
estadiosBug = []
for linea in f:
    linea = linea[:linea.find("\n")]
    campos = linea.split(";")
    if campos[1] == "¿¿¿???" or campos[1] == "0Exp":
        campos[1] = "0"
        estadiosBug.append(campos[0])
    if campos[2] == "¿¿¿???":
        campos[2] = "null"
    fOut.write("INSERT INTO estadios (nombre, capacidad, fechaInauguracion) VALUES (")
    fOut.write("\'" + campos[0] + "\'," + campos[1] + ",\'" + campos[2] + "\');\n")
f.close()
fOut.close()

f = open("estadiosBug.txt","w",encoding="utf-8")
for est in estadiosBug:
    f.write(est + "\n")