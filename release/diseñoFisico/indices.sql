-- primera consulta
CREATE INDEX todos
ON resultados_all (puesto);

-- segunda consulta
CREATE INDEX primera
ON resultados_primera (puesto, partidosGanados);
CREATE INDEX segunda
ON resultados_segunda (puesto, partidosGanados);

-- tercera consulta
CREATE INDEX goles_vista
ON partidos_1vs2 (golesLocal, golesVisitante);