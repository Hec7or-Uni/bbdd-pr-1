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
