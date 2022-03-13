#!/usr/bin/bash
echo "GENERANDO SQL DE ESTADIOS"
python ./insertEstadios.py
echo "GENERANDO SQL DE EQUIPOS"
python ./insertEquipos.py
echo "GENERANDO SQL DE PARTIDOS"
python ./insertPartidos.py
echo "ARCHIVOS PARA POBLAR LA BBDD GENERADOS"
mv *.sql sql