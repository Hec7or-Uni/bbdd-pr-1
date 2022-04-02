INSERT INTO resultados_all
SELECT puesto, partidosGanados, equipo, division, temporada
FROM resultados;

INSERT INTO resultados_primera
SELECT puesto, partidosGanados, equipo, temporada
FROM resultados
WHERE division = '1ª';

INSERT INTO resultados_segunda
SELECT puesto, partidosGanados, equipo, temporada
FROM resultados
WHERE division = '2ª';