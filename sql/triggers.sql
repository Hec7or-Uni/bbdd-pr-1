CREATE OR REPLACE TRIGGER UPT_RESULTADOS 
AFTER UPDATE ON partidos 
FOR EACH ROW
DECLARE var_p NUMBER;
DECLARE var_asc NUMBER;
DECLARE var_des NUMBER;
DECLARE var_eu NUMBER;
BEGIN
    SELECT puesto INTO var_p 
    FROM (
        SELECT ROW_NUMBER() AS puesto, puntos, equipo
        FROM resultados
        WHERE division = :new.division AND temporada = :new.temporada AND numJornada = :new.numJornada;
        ORDER BY puntos
    ) WHERE equipo = :new.equipo

    -- El equipo X 
    IF :old.golesAF > :old.golesEC 
    THEN  
        UPDATE resultados 
        SET puntos=:old.puntos+3, golesAF=:old.golesAF+:new.golesAF, 
            golesEC=:old.golesEC+:new.golesEC, partidosGanados=:old.partidosGanados+1, puesto=var_p
        WHERE equipo = :new.equipo AND division = :new.division AND
              temporada = :new.temporada AND numJornada = :new.numJornada
        --  puesto=value, asciende=value, desciende=value, europa=value
    ELSIF :old.golesAF < :old.golesEC
        UPDATE resultados 
        SET golesAF=:old.golesAF+:new.golesAF, golesEC=:old.golesEC+:new.golesEC,
            partidosPerdidos=:old.partidosPerdidos+1, puesto=var_p
        WHERE equipo = :new.equipo AND division = :new.division AND
              temporada = :new.temporada AND numJornada = :new.numJornada
        --  puesto=value, asciende=value, desciende=value, europa=value
    ELSE  
        UPDATE resultados 
        SET puntos=:old.puntos+1, golesAF=:old.golesAF+:new.golesAF, golesEC=:old.golesEC+:new.golesEC, puesto=var_p
        WHERE equipo = :new.equipo AND division = :new.division AND
              temporada = :new.temporada AND numJornada = :new.numJornada
        --  puesto=value, asciende=value, desciende=value, europa=value
    END IF;

    -- ASCENSOS & EUROPAS
    IF var_p >= 5 AND :new.division='1'  THEN 
        var_asc=0
        var_eu=1
    ELSE IF var_p >= 5 AND :new.division='2'
        var_eu=0 
        IF var_p >= 2 THEN var_asc=1 END IF
    END IF

    -- DESCENSOS
    IF -- SELECT QUE TE DICE SI ESTA O NO ENTRE LOS ULTIMOS PUESTOS
    THEN
        var_des=1
    ELSE
        var_des=0 
    END IF

    UPDATE resultados
    SET asciende=var_asc, desciende=var_des, europa=var_eu
    WHERE equipo = :new.equipo AND division = :new.division AND
          temporada = :new.temporada AND numJornada = :new.numJornada
END; 
/

CREATE OR REPLACE TRIGGER CHECK_PARTIDOS 
BEFORE UPDATE ON partidos 
FOR EACH ROW
BEGIN
    IF :new.local == :new.visitante 
    THEN
        RAISE_APPLICATION_ERROR(-20000, 'ERROR: En un partido, un equipo no puede jugar contra si mismo');
    END IF
END;
/