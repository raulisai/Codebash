#!/bin/bash
host="covid.csuilyfvdede.us-west-2.rds.amazonaws.com"
usuario="covidAdmin"
password="dbCovid2020"
sql="--user=$usuario -p$password --port=3306 --host=$host -s -e"
#fechas
DIA_DE_HOY_DB=$(date +%Y-%m-%d)
DIA_DE_HOY_NOMBRE_REPORTE=$(date +%d%b%Y)
HACE_veintiCinco_DIAS=$(date --date "-25 days" +%Y-%m-%d)
echo "Hoy es $DIA_DE_HOY_DB.."
echo "El rango sera hasta el dia:  $HACE_veintiCinco_DIAS A $DIA_DE_HOY_DB"
#Consultas
echo "cargando 1º reporte............"
mysql $sql "SELECT numero_empleado, id_empleado, correo, nombre, Calificacion,
'Riesgo bajo' AS calificacionRiesgo,
telefono_movil, fecha_creacion
FROM \`covid\`.registro INNER JOIN \`covid\`.cuestionario ON \`covid\`.registro.id_registro = \`covid\`.cuestionario.id_registro
WHERE cast(calificacion AS UNSIGNED)<7 AND fecha_creacion between '$HACE_veintiCinco_DIAS 00:00:59' AND '$DIA_DE_HOY_DB 23:59:59'
UNION
SELECT numero_empleado, id_empleado, correo, nombre, Calificacion,
'Riesgo Medio' AS calificacionRiesgo,
telefono_movil, fecha_creacion
FROM \`covid\`.registro INNER JOIN \`covid\`.cuestionario ON \`covid\`.registro.id_registro = \`covid\`.cuestionario.id_registro
WHERE cast(calificacion AS UNSIGNED)>6 AND cast(calificacion AS UNSIGNED)<12 AND fecha_creacion between '$HACE_veintiCinco_DIAS 00:00:59' AND '$DIA_DE_HOY_DB 23:59:59'
UNION
SELECT numero_empleado,id_empleado, correo, nombre, Calificacion,
'Riesgo Alto' AS calificacionRiesgo,
telefono_movil, fecha_creacion
FROM \`covid\`.registro INNER JOIN \`covid\`.cuestionario ON \`covid\`.registro.id_registro = \`covid\`.cuestionario.id_registro
WHERE cast(calificacion AS UNSIGNED)>11 AND fecha_creacion between '$HACE_veintiCinco_DIAS 00:00:59' AND '$DIA_DE_HOY_DB 23:59:59'
ORDER BY correo, fecha_creacion DESC;" | sed  's/\t/,/g' > /mnt/c/Users/DJOKER/'OneDrive - IZZI Telecom'/Reportes_Izzi_Covid/Reporte_IZZI_Covid$DIA_DE_HOY_NOMBRE_REPORTE.csv

echo "cargando 2º reporte........."
mysql $sql "SELECT R.numero_empleado, R.correo, R.nombre, R.lugar_trabajo, R.telefono_movil, R.telefono_fijo, C.id_cuestionario,C.Calificacion,C.fecha_creacion,
P.pregunta, P.respuesta FROM covid.registro AS R
INNER JOIN covid.cuestionario AS C ON R.id_registro = C.id_registro
INNER JOIN covid.preguntas AS P ON C.id_cuestionario = P.id_cuestionario
WHERE C.fecha_creacion LIKE '2021-01%'  AND C.calificacion > 11
AND P.pregunta like '%perdida del Olfato o Gusto%' AND P.respuesta = '1.0' 
ORDER BY C.id_cuestionario DESC;" | sed  's/\t/,/g' > /mnt/c/Users/DJOKER/'OneDrive - IZZI Telecom'/Reportes_Izzi_Covid/Reportes_Izzi_CovidRiesgoAlto_PerdidaOlfatoGusto$DIA_DE_HOY_NOMBRE_REPORTE.csv

echo "cargando 3º reporte......."
mysql $sql "SELECT id_empleado, numero_empleado, nombre, correo, correo_personal, telefono_movil, telefono_fijo, lugar_trabajo FROM \`covid\`.registro;" | sed  's/\t/,/g' > /mnt/c/Users/DJOKER/'OneDrive - IZZI Telecom'/Reportes_Izzi_Covid/Registro_Covid$DIA_DE_HOY_NOMBRE_REPORTE.csv

echo "Se subiran los archivos.."

