-- CONSULTA 1 OPTIMIZADA:
-- Se podria optimizar más la parte del count?
SELECT DISTINCT equipo
FROM resultados_all
WHERE equipo NOT IN (
    -- Equipos que han ganado al menos una liga
    SELECT DISTINCT equipo
    FROM resultados_all
    WHERE puesto = 1
) AND equipo IN (
    -- Equipos que han estado en primera al menos 5 temporadas
    SELECT equipo
    FROM (
        SELECT count(*) AS veces, equipo
        FROM resultados_primera
        GROUP BY equipo
    ) A
    WHERE A.veces >= 5
)
ORDER BY equipo;

-- CONSULTA 2 OPTIMIZADA:
SELECT T1.temporada
FROM resultados_segunda T1
WHERE T1.puesto = 1
    AND EXISTS (
    SELECT 1
    FROM resultados_primera T2
    WHERE T2.puesto = 1 AND T1.partidosganados > T2.partidosganados AND T2.temporada = T1.temporada
)
ORDER BY T1.temporada;

-- CONSULTA 3 OPTIMIZADA:
SELECT C.equipo, C.temporada
FROM (
    SELECT COUNT(*) as veces, temporada, division
    FROM partidos_1vs2
    GROUP BY temporada, division
) A, (
    SELECT COUNT(*) as veces, temporada, division
    FROM partidos_1vs2
    WHERE (local = campeon AND visitante = subcampeon AND golesLocal < golesVisitante) OR 
        (local = subcampeon AND visitante = campeon AND golesVisitante < golesLocal)
    GROUP BY temporada, division
) B, resultados_all C
WHERE A.temporada = B.temporada AND A.temporada = C.temporada AND A.division = B.division AND A.division = C.division AND
    puesto = 1 AND A.veces = B.veces
ORDER BY A.temporada;