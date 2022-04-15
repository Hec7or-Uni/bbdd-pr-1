-- TRIGGER 1:
CREATE OR REPLACE TRIGGER CHECK_INTEGRIDAD
BEFORE INSERT ON partidos
FOR EACH ROW
DECLARE 
    flag NUMBER;
BEGIN
    SELECT COUNT(*) INTO flag
    FROM partidos 
    WHERE temporada = :NEW.temporada AND division = :NEW.division AND numJornada = :NEW.numJornada AND 
        (local = :NEW.visitante OR visitante = :NEW.visitante);
        
    IF flag >= 1 THEN
        RAISE_APPLICATION_ERROR (-20000, 'Un equipo no puede jugar como local y visitante en la misma jornada.');
    END IF;
END; 
/

-- TRIGGER 2:
CREATE OR REPLACE TRIGGER DATES_OK
BEFORE INSERT ON resultados
FOR EACH ROW
DECLARE 
    fechaFUN NUMBER;
BEGIN
    SELECT fechaFundacion INTO fechaFUN FROM equipos WHERE :NEW.equipo = nombreCorto;
    
    IF :NEW.temporada < fechaFUN
    THEN
        RAISE_APPLICATION_ERROR (-20001, 'El equipo no existe aún en esta temporada');
    END IF;
END;
/

-- TRIGGER 3
CREATE OR REPLACE TRIGGER UPT_RESULTADOS 
FOR INSERT ON partidos 
COMPOUND TRIGGER
    filaLocal           resultados%ROWTYPE;
    filaVisitante       resultados%ROWTYPE;
    puntosLocal         NUMBER;
    puntosVisitante     NUMBER;
    ganaLocal           NUMBER;
    ganaVisitante       NUMBER;
    empate              NUMBER;
    existeParLocA       NUMBER;
    existeParVisA       NUMBER;
    existeResLoc        NUMBER;
    existeResVis        NUMBER;

    -- Garantiza una insercion de los partidos en orden
    BEFORE EACH ROW IS
    BEGIN
        -- El partido que juega local en la jornada anterior no existe
        SELECT COUNT(*) INTO existeParLocA 
        FROM partidos 
        WHERE (local = :NEW.local OR visitante = :NEW.local)  AND 
            temporada = :NEW.temporada AND division = :NEW.division AND numJornada = :NEW.numJornada - 1;
            
        -- El partido que juega visitante en la jornada anterior no existe
        SELECT COUNT(*) INTO  existeParVisA 
        FROM partidos 
        WHERE (local = :NEW.visitante OR visitante = :NEW.visitante) AND 
        temporada = :NEW.temporada AND division = :NEW.division AND numJornada = :NEW.numJornada - 1;

        IF  :NEW.numJornada <> 1 AND NOT (1 <= existeParLocA) OR NOT (1 <= existeParVisA)
        THEN 
            RAISE_APPLICATION_ERROR (-20003, 'Esta tupla esta siendo insertada antes de lo que deberia');
        END IF;
    END BEFORE EACH ROW;

    -- Actualiza la tabla de resultados
    AFTER EACH ROW IS
    BEGIN
        -- captura los resultados antiguos de los 2 equipos insertados
        SELECT * INTO filaLocal 
        FROM resultados 
        WHERE equipo = :NEW.local AND temporada = :NEW.temporada AND division = :NEW.division;
        SELECT * INTO filaVisitante 
        FROM resultados 
        WHERE equipo = :NEW.visitante AND temporada = :NEW.temporada AND division = :NEW.division;
        
        -- Establece los puntos nuevos
        -- Gana el local
        IF :NEW.golesLocal > :NEW.golesVisitante THEN
            puntosLocal := 3;
            puntosVisitante := 0;
            ganaLocal := 1;
            ganaVisitante := 0;
            empate := 0;
        -- Gana el visitante
        ELSIF :NEW.golesLocal < :NEW.golesVisitante THEN
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
       
        -- si existe un resultado para el equipo local
        SELECT COUNT(*) INTO existeResLoc FROM resultados WHERE equipo = :NEW.local AND temporada = :NEW.temporada AND division = :NEW.division;
        -- si existe un resultado para el equipo local
        SELECT COUNT(*) INTO existeResVis FROM resultados WHERE equipo = :NEW.visitante AND temporada = :NEW.temporada AND division = :NEW.division;
        
        IF (1 <= existeResLoc AND 1 <= existeResVis) THEN
            -- Actualiza los resultados del equipo local
            UPDATE RESULTADOS 
            SET 
                PUNTOS  = filaLocal.puntos  + puntosLocal,
                GOLESAF = filaLocal.golesAF + :NEW.golesLocal,
                GOLESEC = filaLocal.golesEC + :NEW.golesVisitante,
                PARTIDOSGANADOS     = filaLocal.partidosGanados   + ganaLocal,
                PARTIDOSEMPATADOS   = filaLocal.partidosEmpatados + empate,
                PARTIDOSPERDIDOS    = filaLocal.partidosPerdidos  + ganaVisitante,
                NUMJORNADA          = :NEW.numJornada
            WHERE EQUIPO = :NEW.local AND DIVISION = :NEW.division AND TEMPORADA = :NEW.temporada;

            -- Actualiza los resultados del equipo visitante
            UPDATE RESULTADOS 
            SET 
                PUNTOS  = filaVisitante.puntos  + puntosVisitante,
                GOLESAF = filaVisitante.golesAF + :NEW.golesVisitante,
                GOLESEC = filaVisitante.golesEC + :NEW.golesLocal,
                PARTIDOSGANADOS     = filaVisitante.partidosGanados   + ganaVisitante,
                PARTIDOSEMPATADOS   = filaVisitante.partidosEmpatados + empate,
                PARTIDOSPERDIDOS    = filaVisitante.partidosPerdidos  + ganaLocal,
                NUMJORNADA          = :NEW.numJornada
            WHERE EQUIPO = :NEW.visitante AND DIVISION = :NEW.division AND TEMPORADA = :NEW.temporada;
        ELSE
            -- Inserta el primer resultado del equipo local
            INSERT INTO 
            RESULTADOS (PUNTOS,GOLESAF,GOLESEC,PARTIDOSGANADOS,PARTIDOSEMPATADOS,PARTIDOSPERDIDOS,EQUIPO,DIVISION,TEMPORADA,NUMJORNADA) 
            VALUES (puntosLocal,:NEW.golesLocal,:NEW.golesVisitante,ganaLocal,empate,ganaVisitante,:NEW.local,:NEW.division,:NEW.temporada,1);
            -- Inserta el primer resultado del equipo visitante
            INSERT INTO
            RESULTADOS (PUNTOS,GOLESAF,GOLESEC,PARTIDOSGANADOS,PARTIDOSEMPATADOS,PARTIDOSPERDIDOS,EQUIPO,DIVISION,TEMPORADA,NUMJORNADA) 
            VALUES (puntosVisitante,:NEW.golesVisitante,:NEW.golesLocal,ganaVisitante,empate,ganaLocal,:NEW.visitante,:NEW.division,:NEW.temporada,1);
        END IF;
        
        -- Zona para recalcular los puestos y ascensos
        -- Consulta que calcula los datos buenos a usar con un update para actualizar la parte de la tabla que nos interese...
        MERGE INTO resultados
        USING (
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
            WHERE R1.temporada = :NEW.temporada AND R1.division = :NEW.division
            ORDER BY R1.division, R1.puesto
        ) N 
        ON (resultados.equipo = N.equipo AND resultados.temporada = :NEW.temporada AND resultados.numJornada = :NEW.numJornada AND resultados.division = :NEW.division)
        WHEN MATCHED THEN UPDATE
        SET 
            resultados.puesto   = N.puesto,
            resultados.asciende = N.asciende,
            resultados.desciende= N.desciende,
            resultados.europa   = N.europa;
    END AFTER EACH ROW;
END UPT_RESULTADOS;
