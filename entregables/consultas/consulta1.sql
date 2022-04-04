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