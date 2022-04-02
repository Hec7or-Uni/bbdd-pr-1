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

    -- Garantiza una insercion de los partidos en orden
    BEFORE EACH ROW IS
    BEGIN
        IF  :NEW.numJornada <> 1 
            AND 
            -- El partido que juega local en la jornada anterior no existe
            NOT (1 = (SELECT 1 FROM partido WHERE equipo = :NEW.local AND temporada = :NEW.temporada AND division = :NEW.division AND numJornada = :NEW.numJornada - 1))
            OR 
            -- El partido que juega visitante en la jornada anterior no existe
            NOT (1 = (SELECT 1 FROM partido WHERE equipo = :NEW.visitante AND temporada = :NEW.temporada AND division = :NEW.division AND numJornada = :NEW.numJornada - 1))
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
        
        IF -- si existe un resultado para el equipo local
            (1 = (SELECT 1 FROM resultados WHERE equipo = :NEW.local AND temporada = :NEW.temporada AND division = :NEW.division)) 
            AND
            -- si existe un resultado para el equipo local
            (1 = (SELECT 1 FROM resultados WHERE equipo = :NEW.visitante AND temporada = :NEW.temporada AND division = :NEW.division))
        THEN
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
        -- SELECT ROW_NUMBER() OVER (ORDER BY puntos DESC) AS puesto, R1.partidosGanados, R1.partidosEmpatados, R1.partidosPerdidos, R1.golesAF, R1.golesEC, R1.puntos, R1.equipo, R1.division, R1.temporada, R1.numJornada, 
        --     CASE
        --         WHEN puesto <= 3 AND division = '2ª' THEN 1
        --     END AS asciende,
        --     CASE
        --         WHEN puesto  >= R2.numEquipos - 1 AND division = '1ª' THEN 1
        --     END AS desciende,
        --     CASE
        --         WHEN puesto <= 5 AND division = '1ª' THEN 1
        --     END AS europa
        -- FROM resultados R1, (
        --     SELECT COUNT(*) AS numEquipos
        --     FROM resultados
        --     WHERE temporada = :NEW.temporada AND division = :NEW.division
        -- ) R2
        -- WHERE temporada = :NEW.temporada AND division = :NEW.division
        -- ORDER BY division, puesto;
    END AFTER EACH ROW;
END UPT_RESULTADOS;