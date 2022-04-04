-- CONSULTA 3:
-- Equipo(s) y temporada(s) donde dicho equipo ha ganado dicha temporada,
-- habiendo perdido todos los partidos contra el equipo que quedó en segunda posición.
SELECT C.equipo, C.temporada
FROM (
    SELECT COUNT(*) as veces, R.temporada, R.division
    FROM partidos P, (
        -- Devuelve pares de ganador, subcampeon
        SELECT DISTINCT A.puesto AS puesto_1, A.equipo AS campeon, B.puesto AS puesto_2, B.equipo AS subcampeon, A.temporada, A.division, A.numJornada
        FROM resultados A, resultados B 
        WHERE A.puesto = 1 AND B.puesto = 2 AND A.division = B.division AND A.temporada = B.temporada
    ) R
    WHERE ((P.local = R.campeon AND P.visitante = R.subcampeon) OR (P.local = R.subcampeon AND P.visitante = R.campeon))
        AND P.division = R.division AND P.temporada = R.temporada
    GROUP BY R.temporada, R.division
) A, (
    SELECT COUNT(*) as veces, R.temporada, R.division
    FROM partidos P, (
        -- Devuelve pares de ganador, subcampeon
        SELECT DISTINCT A.puesto AS puesto_1, A.equipo AS campeon, B.puesto AS puesto_2, B.equipo AS subcampeon, A.temporada, A.division, A.numJornada
        FROM resultados A, resultados B 
        WHERE A.puesto = 1 AND B.puesto = 2 AND A.division = B.division AND A.temporada = B.temporada
    ) R
    WHERE ((P.local = R.campeon AND P.visitante = R.subcampeon AND P.goleslocal < P.golesvisitante) OR (P.local = R.subcampeon AND P.visitante = R.campeon AND P.goleslocal > P.golesvisitante))
        AND P.division = R.division AND P.temporada = R.temporada
    GROUP BY R.temporada, R.division
) B, resultados C
WHERE A.veces = B.veces AND A.temporada = B.temporada AND A.division = B.division
    AND A.temporada = C.temporada AND A.division = C.division AND puesto = 1
ORDER BY A.temporada;
