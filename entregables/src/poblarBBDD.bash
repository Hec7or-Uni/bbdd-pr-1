#!/usr/bin/bash
echo "SCRAPEANDO EQUIPOS"
python ./teamScrapper.py
echo "SCRAPEANDO ESTADIOS"
python ./estadioScrapper.py
echo "GENERANDO SQL DE ESTADIOS"
python ./insertEstadios.py
echo "GENERANDO SQL DE EQUIPOS"
python ./insertEquipos.py
echo "GENERANDO SQL DE PARTIDOS"
python ./insertPartidos.py
echo "ARCHIVOS PARA POBLAR LA BBDD GENERADOS"
mv *.sql sql