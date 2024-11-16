########################## Info ################################

#Script_pts_shapefile_a_csv.R


############################### INSTALATION ##########################
rm(list = ls()) # Borramos todos los objetos que est?n creados

# Cargar las librerías necesarias
library(dismo)
library(terra)
library(dplyr)
library(sf)   # Para trabajar con shapefiles
library(sp)   # Para convertir coordenadas si es necesario
######################################################################
setwd("C:/Users/vacas/Desktop/master geoinformatica/ASIGNATURAS/Modelizacion/FRESNO")  # Cambia esto por la ruta de tu directorio de trabajo
getwd() # para saber en que directorio estoy trabajando
#################################################################################
# Ruta al archivo shapefile
shapefile_path <- "FRESNO_dentro_Madrid_points.shp"  # Cambia esto por la ruta de tu shapefile

# Leer el archivo shapefile
shp_data <- st_read(shapefile_path)
plot(ptos_fresno, col = 'black')
# Comprobar que el shapefile contiene geometrías de puntos
if (!all(st_geometry_type(shp_data) %in% c("POINT", "MULTIPOINT"))) {
  stop("El shapefile no contiene geometrías de tipo punto.")
}

# Extraer las coordenadas de los puntos
coordinates <- st_coordinates(shp_data)

# Convertir las coordenadas en un data frame
coordinates_df <- data.frame(
  ID = seq_len(nrow(coordinates)),  # Agregar un ID único para cada punto
  X = coordinates[, "X"],
  Y = coordinates[, "Y"]
)

# Agregar atributos del shapefile (si es necesario)
if (ncol(shp_data) > 1) {
  attributes_df <- as.data.frame(shp_data)
  attributes_df$geometry <- NULL  # Eliminar la columna de geometrías
  coordinates_df <- cbind(coordinates_df, attributes_df)
}

# Guardar las coordenadas en un archivo CSV
csv_path <- "C:/Users/vacas/Desktop/master geoinformatica/ASIGNATURAS/Modelizacion/FRESNO/FRESNO_PUNTAZOS.csv"  # Cambia esto por la ruta donde deseas guardar el CSV
write.csv(coordinates_df, csv_path, row.names = FALSE)
