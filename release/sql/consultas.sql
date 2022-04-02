-- CONSULTA 1:
-- Equipos que han estado en primera división un mínimo de 
-- cinco temporadas y que no han ganado ninguna liga
SELECT DISTINCT equipo
FROM resultados
WHERE equipo NOT IN (
    -- Equipos que han ganado al menos una liga
    SELECT DISTINCT equipo
    FROM resultados
    WHERE puesto = 1
) AND equipo IN (
    -- Equipos que han estado en primera al menos 5 temporadas
    SELECT equipo
    FROM (
        SELECT count(*) AS veces, equipo
        FROM resultados
        WHERE division = '1ª'
        GROUP BY equipo
    ) A
    WHERE A.veces >= 5
)
ORDER BY equipo;

-- CONSULTA 2:
-- Temporadas en las que el ganador de segunda división
-- ha ganado más partidos que el ganador de primera división
SELECT T1.temporada
FROM resultados T1
WHERE T1.division = '2ª' AND T1.puesto = 1
    AND EXISTS (
    -- devuelve una "tupla"/"flag" cuando se cumple que el ganador de segunda
    -- ha ganado mas partidos que el de primera / temporada
    SELECT 1
    FROM resultados T2
    WHERE T2.division = '1ª' AND T2.puesto = 1
    AND T1.partidosganados > T2.partidosganados
    AND T2.temporada = T1.temporada
)
ORDER BY T1.temporada;

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