-- TRIGGER 3:
CREATE OR REPLACE TRIGGER UPT_RESULTADOS
AFTER INSERT ON partidos
DECLARE
    filaLocal           partidos%ROWTYPE
    filaVisitante       partidos%ROWTYPE
    puntosLocal         NUMBER
    puntosVisitante     NUMBER
    ganaLocal           NUMBER
    ganaVisitante       NUMBER
    empate              NUMBER
    
FOR EACH ROW
BEGIN
--  puesto, asciende, desciende, europa,
--  puntos, golesAF, golesEC, partidosGanados, partidosEmpatados, partidosPerdidos
--  equipo, temporada, numJornada, division

    SELECT * INTO filaLocal
    FROM resultados 
    WHERE equipo = :NEW.local AND temporada = :NEW.temporada AND division = :NEW.division

    SELECT * INTO filaVisitante
    FROM resultados 
    WHERE equipo = :NEW.visitante AND temporada = :NEW.temporada AND division = NEW.division


    -- DEBUG Y PREGUNTAR A MONICA SOBRE QUE OCURRE SI LA TABLA ES VACIA
    IF filaLocal.numJornada <= :NEW.numJornada THEN
        RAISE_APPLICATION_ERROR (-20002, 'Las tuplas que se inserten deben de ser más recientes.');
    END IF;

    -- Gana el local
    IF :NEW.golesLocal > :NEW.golesVisitante THEN
        puntosLocal = 3
        puntosVisitante = 0
        ganaLocal = 1
        ganaVisitante = 0
        empate = 0
    -- Gana el visitante
    ELSE IF :NEW.golesLocal < :NEW.golesVisitante THEN
        puntosLocal = 0
        puntosVisitante = 3
        ganaLocal = 0
        ganaVisitante = 1
        empate = 0
    -- Empatan el partido
    ELSE
        puntosLocal = 1
        puntosVisitante = 1
        ganaLocal = 0
        ganaVisitante = 0
        empate = 1
    END IF;
    
    
    -- INSERT LOCAL
    INSERT INTO 
    RESULTADOS (PUNTOS, PUESTO, GOLESAF, GOLESEC, PARTIDOSGANADOS, PARTIDOSEMPATADOS,PARTIDOSPERDIDOS,ASCIENDE,DESCIENDE,EUROPA,EQUIPO,DIVISION,TEMPORADA, NUMJORNADA) 
    VALUES (filaLocal.puntos + puntosLocal, NULL, filaLocal.golesAF + :NEW.golesLocal, filaLocal.golesEC + :NEW.golesVisitante, filaLocal.partidosGanados + ganaLocal, filaLocal.partidosEmpatados + empate, filaLocal.partidosPerdidos + ganaVisitante, NULL, NULL, NULL, filaLocal.equipo,filaLocal.division,filaLocal.temporada, :NEW.jornada);

     -- INSERT Visitante
    INSERT INTO 
    RESULTADOS (PUNTOS,PUESTO,GOLESAF,GOLESEC,PARTIDOSGANADOS,PARTIDOSEMPATADOS,PARTIDOSPERDIDOS,ASCIENDE,DESCIENDE,EUROPA,EQUIPO,DIVISION,TEMPORADA,NUMJORNADA) 
    VALUES (filaVisitante.puntos + puntosVisitante, NULL, filaVisitante.golesAF + :NEW.golesVisitante, filaVisitante.golesEC + :NEW.golesLocal, filaVisitante.partidosGanados + ganaVisitante,filaVisitante.partidosEmpatados + empate, filaVisitante.partidosPerdidos + ganaLocal, NULL, NULL, NULL, filaVisitante.equipo, filaVisitante.division, filaVisitante.temporada, :NEW.jornada);
END;
/