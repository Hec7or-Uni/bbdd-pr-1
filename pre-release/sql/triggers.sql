CREATE OR REPLACE TRIGGER UPT_RESULTADOS 
AFTER INSERT ON partidos
FOR EACH ROW
DECLARE var_p NUMBER;       -- puesto del equipo
DECLARE var_asc NUMBER;     -- [1|0] bool si aciende o no
DECLARE var_des NUMBER;     -- [1|0] bool si desciende o no
DECLARE var_eu NUMBER;      -- [1|0] bool si va a europa o no
DECLARE var_puestos NUMBER;  -- numero de puestos en una liga / temp
BEGIN
    -- calcula el puesto de un equipo
    SELECT puesto INTO var_p 
    FROM (
        SELECT puntos, equipo, ROW_NUMBER() 
        OVER (ORDER BY puntos ASC) AS puesto
        FROM resultados
        WHERE division = :new.division AND temporada = :new.temporada AND numJornada = :new.numJornada;
    ) WHERE equipo = :new.equipo;

    -- Calcula el total de puestos para una division, temporada
    -- no es necesaria la jornada puesto que siempre se mantiene la ultima
    SELECT COUNT(*) AS puestos INTO var_puestos
    FROM resultados
    WHERE division = :new.division AND temporada = :new.temporada;

    -- ASCENSOS & EUROPAS
    IF var_p >= 5 AND :new.division = '1'
    THEN 
        var_asc=0
        var_eu=1
        var_des=0
    ELSE IF var_p >= 2 AND :new.division = '2'
        var_eu=0 
        var_asc=1
        var_des=0
    END IF;

    -- DESCENSOS
    IF var_p > var_puestos - 2 AND :new.division = '1'
    THEN
        var_des=1
    ELSE
        var_des=0 
    END IF;

    IF :old.golesAF > :old.golesEC 
    THEN  
        UPDATE resultados 
        SET puntos=:old.puntos+3, golesAF=:old.golesAF+:new.golesAF, 
            golesEC=:old.golesEC+:new.golesEC, partidosGanados=:old.partidosGanados+1, puesto=var_p,
            asciende=var_asc, desciende=var_des, europa=var_eu
        WHERE equipo = :new.equipo AND division = :new.division AND
              temporada = :new.temporada AND numJornada = :new.numJornada
    ELSIF :old.golesAF < :old.golesEC
        UPDATE resultados 
        SET golesAF=:old.golesAF+:new.golesAF, golesEC=:old.golesEC+:new.golesEC,
            partidosPerdidos=:old.partidosPerdidos+1, puesto=var_p,
            asciende=var_asc, desciende=var_des, europa=var_eu
        WHERE equipo = :new.equipo AND division = :new.division AND
              temporada = :new.temporada AND numJornada = :new.numJornada
    ELSE  
        UPDATE resultados 
        SET puntos=:old.puntos+1, golesAF=:old.golesAF+:new.golesAF, golesEC=:old.golesEC+:new.golesEC, puesto=var_p,
            asciende=var_asc, desciende=var_des, europa=var_eu
        WHERE equipo = :new.equipo AND division = :new.division AND
              temporada = :new.temporada AND numJornada = :new.numJornada
    END IF;
END; 
/