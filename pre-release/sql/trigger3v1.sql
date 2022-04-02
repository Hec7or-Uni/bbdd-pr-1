-- TRIGGER 3:
CREATE OR REPLACE TRIGGER UPT_RESULTADOS
AFTER INSERT ON partidos
FOR EACH ROW
DECLARE
    filaLocal           resultados%ROWTYPE;
    filaVisitante       resultados%ROWTYPE;
    puntosLocal         NUMBER;
    puntosVisitante     NUMBER;
    ganaLocal           NUMBER;
    ganaVisitante       NUMBER;
    empate              NUMBER;
BEGIN
    -- Gana el local
    IF :NEW.golesLocal > :NEW.golesVisitante THEN
        puntosLocal := 3;
        puntosVisitante := 0;
        ganaLocal := 1;
        ganaVisitante := 0;
        empate := 0;
    -- Gana el visitante
    ELSE IF :NEW.golesLocal < :NEW.golesVisitante THEN
        puntosLocal := 0;
        puntosVisitante := 3;
        ganaLocal := 0;
        ganaVisitante := 1;
        empate := 0;
    -- Empatan el partido
    ELSE
        puntosLocal := 1;
        puntosVisitante := 1;
        ganaLocal := 0;
        ganaVisitante := 0;
        empate := 1;
    END IF;
    
    SELECT * INTO filaLocal 
    FROM resultados 
    WHERE equipo = :NEW.local AND temporada = :NEW.temporada AND division = :NEW.division;
    
    SELECT * INTO filaVisitante 
    FROM resultados 
    WHERE equipo = :NEW.visitante AND temporada = :NEW.temporada AND division = :NEW.division;

    -- condiciones
    -- comprueba que existen ambos equipos en la tabla
    IF  (1 = (SELECT 1 FROM resultados WHERE equipo = :NEW.local AND temporada = :NEW.temporada AND division = :NEW.division)) 
        AND 
        (1 = (SELECT 1 FROM resultados WHERE equipo = :NEW.visitante AND temporada = :NEW.temporada AND division = :NEW.division))
    THEN
        -- comprueba que se inserta la tupla 
        IF (filaLocal.numJornada + 1 = :NEW.numJornada) AND (filaVisitante.numJornada + 1 = :NEW.numJornada) THEN
            -- UPDATE LOCAL
            UPDATE RESULTADOS 
            SET 
                PUNTOS  = filaLocal.puntos + puntosLocal,
                GOLESAF = filaLocal.golesAF + :NEW.golesLocal,
                GOLESEC = filaLocal.golesEC + :NEW.golesVisitante,
                PARTIDOSGANADOS     = filaLocal.partidosGanados + ganaLocal,
                PARTIDOSEMPATADOS   = filaLocal.partidosEmpatados + empate,
                PARTIDOSPERDIDOS    = filaLocal.partidosPerdidos + ganaVisitante,
                NUMJORNADA  = :NEW.jornada,
                PUESTO = NULL, ASCIENDE = NULL, DESCIENDE = NULL, EUROPA = NULL
            WHERE EQUIPO = :NEW.local AND DIVISION = :NEW.division AND TEMPORADA = :NEW.temporada;

            -- UPDATE Visitante
            UPDATE RESULTADOS 
            SET 
                PUNTOS  = filaVisitante.puntos + puntosVisitante,
                GOLESAF = filaVisitante.golesAF + :NEW.golesVisitante,
                GOLESEC = filaVisitante.golesEC + :NEW.golesLocal,
                PARTIDOSGANADOS     = filaVisitante.partidosGanados + ganaVisitante,
                PARTIDOSEMPATADOS   = filaVisitante.partidosEmpatados + empate,
                PARTIDOSPERDIDOS    = filaVisitante.partidosPerdidos + ganaLocal,
                NUMJORNADA  = :NEW.jornada,
                PUESTO = NULL, ASCIENDE = NULL, DESCIENDE = NULL, EUROPA = NULL
            WHERE EQUIPO = :NEW.visitante AND DIVISION = :NEW.division AND TEMPORADA = :NEW.temporada;
        ELSE
            -- error -> esta fila debe insertarse despues de alguna otra
            RAISE_APPLICATION_ERROR (-20003, 'Esta tupla esta siendo insertada antes de lo que deberia');
        END IF;
    ELSE IF 
        NOT ((1 = (SELECT 1 FROM resultados WHERE equipo = :NEW.local AND temporada = :NEW.temporada AND division = :NEW.division)) 
        AND 
        (1 = (SELECT 1 FROM resultados WHERE equipo = :NEW.visitante AND temporada = :NEW.temporada AND division = :NEW.division)))
    THEN
        -- INSERT LOCAL
        INSERT INTO 
        RESULTADOS (PUNTOS, PUESTO, GOLESAF, GOLESEC, PARTIDOSGANADOS, PARTIDOSEMPATADOS,PARTIDOSPERDIDOS,ASCIENDE,DESCIENDE,EUROPA,EQUIPO,DIVISION,TEMPORADA, NUMJORNADA) 
        VALUES (puntosLocal, NULL, :NEW.golesLocal, :NEW.golesVisitante, ganaLocal, empate, ganaVisitante, NULL, NULL, NULL, :NEW.local, :NEW.division, :NEW.temporada, :NEW.jornada);
        
        -- INSERT VISITANTE
        INSERT INTO 
        RESULTADOS (PUNTOS,PUESTO,GOLESAF,GOLESEC,PARTIDOSGANADOS,PARTIDOSEMPATADOS,PARTIDOSPERDIDOS,ASCIENDE,DESCIENDE,EUROPA,EQUIPO,DIVISION,TEMPORADA,NUMJORNADA) 
        VALUES (puntosVisitante, NULL, :NEW.golesVisitante, :NEW.golesLocal, ganaVisitante, empate, ganaLocal, NULL, NULL, NULL, :NEW.visitante, :NEW.division, :NEW.temporada, :NEW.jornada);
    ELSE
        -- error -> esta fila debe insertarse despues de alguna otra
        RAISE_APPLICATION_ERROR (-20003, 'Esta tupla esta siendo insertada antes de lo que deberia');
    END IF;
    
    SELECT ROW_NUMBER() OVER (ORDER BY puntos DESC) AS puesto, R1.partidosGanados, R1.partidosEmpatados, R1.partidosPerdidos, R1.golesAF, R1.golesEC, R1.puntos, R1.equipo, R1.division, R1.temporada, R1.numJornada, 
        CASE
            WHEN puesto <= 3 AND division = '2ª' THEN 1
        END AS asciende,
        CASE
            WHEN puesto  >= R2.numEquipos - 1 AND division = '1ª' THEN 1
        END AS desciende,
        CASE
            WHEN puesto <= 5 AND division = '1ª' THEN 1
        END AS europa
    FROM resultados R1, (
        SELECT COUNT(*) AS numEquipos
        FROM resultados
        WHERE temporada = :NEW.temporada AND division = :NEW.division
    ) R2
    WHERE :NEW.temporada AND division = :NEW.division
    ORDER BY division, puesto;
END;
/