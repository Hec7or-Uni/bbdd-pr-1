INSERT INTO resultados (puntos, golesAF, golesEC, partidosGanados, partidosEmpatados, partidosPerdidos, equipo, division, temporada, numJornada)
SELECT (A.PG * 3 + B.PE) AS puntos, D.GA, D.GC, A.PG, B.PE, C.PP, A.equipo, A.division, A.temporada, E.jornada
FROM (
	SELECT (A.PGL + B.PGV) AS PG, A.equipo, A.temporada, A.division
	FROM (
		SELECT count(*) as PGL, local as equipo, temporada, division
		FROM partidos
		WHERE golesLocal > golesVisitante
		GROUP BY equipo, temporada, division
	) A, (
		SELECT count(*) as PGV, visitante as equipo, temporada, division
		FROM partidos
		WHERE golesLocal < golesVisitante
		GROUP BY equipo, temporada, division
	) B
	WHERE A.equipo = B.equipo
	GROUP BY equipo, temporada, division
) A, (
	SELECT (A.PEL + B.PEV) AS PE, A.equipo, A.temporada, A.division
	FROM (
		SELECT count(*) as PEL, local as equipo, temporada, division
		FROM partidos
		WHERE golesLocal = golesVisitante
		GROUP BY equipo, temporada, division
	) A, (
		SELECT count(*) as PEV, visitante as equipo, temporada, division
		FROM partidos
		WHERE golesLocal = golesVisitante
		GROUP BY equipo, temporada, division
	) B
	WHERE A.equipo = B.equipo
	GROUP BY equipo, temporada, division
) B, (
	SELECT (A.PPL + B.PPV) AS PP, A.equipo, A.temporada, A.division
	FROM (
		SELECT count(*) as PPL, local as equipo, temporada, division
		FROM partidos
		WHERE golesLocal < golesVisitante
		GROUP BY equipo, temporada, division
	) A, (
		SELECT count(*) as PPV, visitante as equipo, temporada, division
		FROM partidos
		WHERE golesLocal > golesVisitante
		GROUP BY equipo, temporada, division
	) B
	WHERE A.equipo = B.equipo
	GROUP BY equipo, temporada, division
) C, (
	SELECT (A.GA + B.GA) AS GA, (A.GC + B.GC) AS GC, A.equipo, A.temporada, A.division
	FROM (
		SELECT sum(golesLocal) AS GA, sum(golesVisitante) AS GC, local AS equipo, temporada, division, max(numJornada) AS final
		FROM partidos
		GROUP BY temporada, division, local
	) A, (
		SELECT sum(golesVisitante) AS GA, sum(golesLocal) AS GC, visitante AS equipo, temporada, division, max(numJornada) AS final
		FROM partidos    
		GROUP BY temporada, division, visitante
	) B
	WHERE A.equipo = B.equipo
	GROUP BY A.equipo, A.temporada, A.division
) D, (
	SELECT division, temporada, max(numJornada) as jornada
    FROM partidos
    GROUP BY division, temporada
) E
WHERE A.equipo = B.equipo AND B.equipo = C.equipo AND C.equipo = D.equipo AND A.temporada = E.temporada AND A.division = E.division AND A.temporada = xxxx
GROUP BY A.equipo, A.temporada, A.division
ORDER BY A.temporada, A.division, puntos DESC;