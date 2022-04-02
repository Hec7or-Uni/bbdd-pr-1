CREATE MATERIALIZED VIEW partidos_1vs2 AS
SELECT P.goleslocal, P.golesvisitante, P.local, P.visitante, R.puesto_1, R.campeon, R.puesto_2, R.subcampeon, R.temporada, R.division, P.numJornada
FROM partidos P, ( 
    SELECT DISTINCT A.puesto AS puesto_1, A.equipo AS campeon, B.puesto AS puesto_2, B.equipo AS subcampeon, A.temporada, A.division, A.numJornada
    FROM resultados A, resultados B 
    WHERE A.puesto = 1 AND B.puesto = 2 AND A.division = B.division AND A.temporada = B.temporada
) R
WHERE ((P.local = R.campeon AND P.visitante = R.subcampeon) OR (P.local = R.subcampeon AND P.visitante = R.campeon)) AND 
    R.division = P.division AND R.temporada = P.temporada;