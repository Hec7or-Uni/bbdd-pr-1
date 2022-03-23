from numpy import False_


def puntua(a:int, b:int) -> int:
    if a > b: return 3
    elif a == b: return 1
    else: return 0

equipos1 = []
puntuaciones1 = []
golesAF1 = []
golesEC1 = []
partidosGanados1 = []
partidosPerdidos1 = []
equipos2 = []
puntuaciones2 = []
golesAF2 = []
golesEC2 = []
partidosGanados2 = []
partidosPerdidos2 = []
lineasTemp = []

def sorting(a,b,c,d,e,f):
    for i in range(0,len(a) - 1):
        for j in range(i,len(a) - 1):
            if(a[i] < a[j]):
                auxA = a[i]
                a[i] = a[j]
                a[j] = auxA

                auxB = b[i]
                b[i] = b[j]
                b[j] = auxB

                auxc = c[i]
                c[i] = c[j]
                c[j] = auxc

                auxd = d[i]
                d[i] = d[j]
                d[j] = auxd

                auxe = e[i]
                e[i] = e[j]
                e[j] = auxe

                auxf = f[i]
                f[i] = f[j]
                f[j] = auxf


for a in range(0, 44):
    lineasTemp.append([])

# lectura del fichero
f = open("partidos.csv" , 'r')
f.readline()

first = False
for linea in f:
    l = linea[:-1].split(",")
    y = int(l[5])
    if not first:
        firstYear = y
        first = True
    lineasTemp[y - firstYear].append(l)
f.close()
fOut = open("resultados.csv" , "w" , encoding="utf-8")
fOut.write("puntuacion,puesto,golesAF,golesEC,partidosGanados,partidosPerdidos,equipo,temporada,división\n")
first = False_
for temp in lineasTemp:
    equipos1.clear()
    puntuaciones1.clear()
    golesAF1.clear()
    golesEC1.clear()
    partidosGanados1.clear()
    partidosPerdidos1.clear()
    equipos2.clear()
    puntuaciones2.clear()
    golesAF2.clear()
    golesEC2.clear()
    partidosGanados2.clear()
    partidosPerdidos2.clear()
    for linea in temp:
        puntosLocal = puntua(int(linea[0]),int(linea[1]))
        puntosVisistante = puntua(int(linea[1]),int(linea[0]))
        if linea[4] == "1ª":
            if linea[2] not in equipos1:
                equipos1.append(linea[2])
                puntuaciones1.append(0)
                golesAF1.append(0)
                golesEC1.append(0)
                partidosGanados1.append(0)
                partidosPerdidos1.append(0)

            if linea[3] not in equipos1:
                equipos1.append(linea[3])
                puntuaciones1.append(0)
                golesAF1.append(0)
                golesEC1.append(0)
                partidosGanados1.append(0)
                partidosPerdidos1.append(0)

            puntuaciones1[equipos1.index(linea[2])] += puntosLocal
            puntuaciones1[equipos1.index(linea[3])] += puntosVisistante
            
            golesAF1[equipos1.index(linea[2])] += int(linea[0])
            golesAF1[equipos1.index(linea[3])] += int(linea[1])
            golesEC1[equipos1.index(linea[2])] += int(linea[1])
            golesEC1[equipos1.index(linea[3])] += int(linea[0])

            partidosGanados1[equipos1.index(linea[2])] += int(puntosLocal == 3)
            partidosGanados1[equipos1.index(linea[3])] += int(puntosVisistante == 3)
            partidosPerdidos1[equipos1.index(linea[2])] += int(puntosVisistante == 3)
            partidosPerdidos1[equipos1.index(linea[3])] += int(puntosLocal == 3)
        else:
            if linea[2] not in equipos2:
                equipos2.append(linea[2])
                puntuaciones2.append(0)
                golesAF2.append(0)
                golesEC2.append(0)
                partidosGanados2.append(0)
                partidosPerdidos2.append(0)

            if linea[3] not in equipos2:
                equipos2.append(linea[3])
                puntuaciones2.append(0)
                golesAF2.append(0)
                golesEC2.append(0)
                partidosGanados2.append(0)
                partidosPerdidos2.append(0)

            puntuaciones2[equipos2.index(linea[2])] += puntosLocal
            puntuaciones2[equipos2.index(linea[3])] += puntosVisistante
            
            golesAF2[equipos2.index(linea[2])] += int(linea[0])
            golesAF2[equipos2.index(linea[3])] += int(linea[1])
            golesEC2[equipos2.index(linea[2])] += int(linea[1])
            golesEC2[equipos2.index(linea[3])] += int(linea[0])

            partidosGanados2[equipos2.index(linea[2])] += int(puntosLocal == 3)
            partidosGanados2[equipos2.index(linea[3])] += int(puntosVisistante == 3)
            partidosPerdidos2[equipos2.index(linea[2])] += int(puntosVisistante == 3)
            partidosPerdidos2[equipos2.index(linea[3])] += int(puntosLocal == 3)

    sorting(puntuaciones1,equipos1,golesAF1,golesEC1,partidosGanados1,partidosPerdidos1)
    sorting(puntuaciones2,equipos2,golesAF2,golesEC2,partidosGanados2,partidosPerdidos2)
    for a in range(0,len(equipos1) - 1):
        fOut.write(str(puntuaciones1[a]) + "," + str(a) + "," + str(golesAF1[a]) + "," + str(golesEC1[a]) + ",")
        fOut.write(str(partidosGanados1[a]) + "," + str(partidosPerdidos1[a]) + "," + equipos1[a] + "," + str(lineasTemp.index(temp) + firstYear) + "," + "1ª" + "\n")
    for a in range(0,len(equipos2) - 2):
        fOut.write(str(puntuaciones2[a]) + "," + str(a) + "," + str(golesAF2[a]) + "," + str(golesEC2[a]) + ",")
        fOut.write(str(partidosGanados2[a]) + "," + str(partidosPerdidos2[a]) + "," + equipos2[a] + "," + str(lineasTemp.index(temp) + firstYear) + "," + "2ª" + "\n")

f.close()

# puntos             
# puesto             
# golesAF            
# golesEC            
# partidosGanados    
# partidosPerdidos   
# asciende           
# desciende          
# europa             
# equipo     
# division    
# temporada   
# numJornada