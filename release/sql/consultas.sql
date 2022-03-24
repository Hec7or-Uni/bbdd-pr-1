-- CONSULTA 1:
-- Equipos que han estado en primera división un mínimo de 
-- cinco temporadas y que no han ganado ninguna liga
SELECT equipo
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
GROUP BY equipo
ORDER BY equipo;

-- CONSULTA 2:
-- Temporadas en las que el ganador de segunda división
-- ha ganado más partidos que el ganador de primera división
SELECT T1.temporada
FROM resultados T1
WHERE T1.division =  '2ª' AND T1.puesto = 1
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