########################## Info ################################

#SCRIPT para cojer los puntos de fresno de la comunidad de madrid


############################### INSTALATION ##########################
rm(list = ls()) # Borramos todos los objetos que est?n creados

# Cargar las librerías necesarias
library(dismo)
library(terra)
library(dplyr)
library(sf)   # Para trabajar con shapefiles
library(sp)   # Para convertir coordenadas si es necesario

# Configuración del directorio de trabajo
setwd("C:/Users/vacas/Desktop/master geoinformatica/ASIGNATURAS/Modelizacion/FRESNO")  # Cambia esto por la ruta de tu directorio de trabajo
getwd() # para saber en que directorio estoy trabajando
#################################################################################
madrid <- vect('vect/recintos_autonomicas_inspire_peninbal_etrs89.shp')
plot(madrid, col = 'black')


###############################################################################################
# DISTRIBUCION DE ESPECIES
###############################################################################################
###############################################################################################
#cargar csv, si esta separado por tabuladores o huecos se pone \t
gbif <- read.csv('taxa/Fraxinus_excelsior_GBIF.csv', sep = ',')
dim(gbif)
names(gbif)

# Creación de un objeto de tipo vector con coordenadas
temp <- vect(gbif, geom = c('lon', 'lat'), crs = 'EPSG:4326')
plot(madrid, col = 'light gray')
plot(temp, col = 'red', pch = 19, add = TRUE) # si no pongo add=TRUE me borra el mapa anterior. puesto asi se pone uno encima de otro
###############################################################################################
###############################################################################################
# SELECCION DE COLUMNAS Y DATOS A TRABAJAR
###############################################################################################
###############################################################################################
# Selección de columnas, nos quedamos con la info que nos interesa de la base de datos
names(gbif)
data <- gbif[, c("acceptedScientificName", "lon", "lat", "country")] # ojo a la coma, hay que ponerla SI COJEMOS TODAS LAS FILAS Y DESPUES LAS COLUMNAS QUE QUERAMOS SELECCIONAR
colnames(data) <- c("species", "lon", "lat", "ISO2") #RENOMBRAR LAS COLUMNAS
head(data)

# Guardar los datos seleccionados en un archivo CSV
write.csv(data, "FRESNO_data.csv", row.names = FALSE)
###############################################################################################
###############################################################################################
# SELECCION DE REGION GEOGRAFICA
###############################################################################################
###############################################################################################
# Selección de región geográfica

# Primera selección de datos geográficos

cd_madrid <- subset(data, lon > -5 & lon < -2.5 & lat > 39.7 & lat < 41.5)
dim(cd_madrid)

# OPCION1:Crear objeto de vector y graficar######################################
temp <- vect(cd_madrid, geom = c('lon', 'lat'), crs = 'EPSG:4326')
plot(madrid, col = 'light gray', xlim = c(-5, -2.5), ylim = c(39.7, 41.5))
plot(temp, col = 'red', pch = 19, add = TRUE)

# OPCION 2:Segunda selección de datos geográficos con condiciones adicionales. ASI HACEMOS ZOOM##############
cd_madrid2 <- subset(data, lon > -5 & lon < -2.5 & lat > 39.7 & lat < 41.5 & ISO2 == 'Spain')
dim(cd_madrid2)

# temp <- vect(cd, geom = c('lon', 'lat'), crs = 'EPSG:4326')
# plot(madrid, col = 'light gray', xlim = c(-10, 5), ylim = c(35, 44))
# plot(temp, col = 'red', pch = 19, add = TRUE)
###############################################################################################
###############################################################################################
# ELIMINACION DE DUPLICADOS
###############################################################################################
###############################################################################################
# Visualizar dimensiones iniciales del conjunto de datos
dim(cd_madrid2) # saber cuantas observaciones tiene la base de datos llamada "cd"

# Identificación y eliminación de duplicados
#El comando dice que filas estan duplicadas
dups <- duplicated(cd_madrid2) #con esto selecciona los duplicados
data_clean <- cd_madrid2[!dups, ] # le decimos que borrara (filas,columnas) filas: las duplicadas, columnas todas por eso lo dejo en blanco 
# el simbulo ! significa NO
dim(data_clean) #saber cuantas observaciones tiene la nueva sin duplicados
# Guardar el nuevo conjunto de datos limpio en un archivo CSV
write.csv(data_clean, "FRESNO_clean.csv", row.names = FALSE)

###############################################################################################
###############################################################################################
# AJUSTE AL TAMAÑO DE PIXEL
###############################################################################################
###############################################################################################
# # Cargar el conjunto de datos limpio
# data <- read.csv('FRESNO_clean.csv', sep = ',')
# dim(data)
# TWI<- rast("C:/Users/vacas/Desktop/master geoinformatica/ASIGNATURAS/Modelizacion/FRESNO/rast/twi_mad.tif")
# 
# # Identificar celdas de píxeles únicas( QUITAR PUNTOS DUPLICADOS PORQUE ESTAN MUY PROXIMOS PARA MI TAMAÑO DE PIXEL)
# # ejemplo yo mi primo y el de la moto an pasado y han visto el mismo gorrion en puntos muy proximos, son uno vale!!
# cells <- terra::cellFromXY(TWI, data[c('lon', 'lat')])
# cells <- unique(cells)
# xy <- terra::xyFromCell(TWI, cells)
# 
# # Crear un nuevo conjunto de datos con coordenadas únicas
# new_data <- data.frame(species = 'Fraxinus excelsior L.', lon = xy[,1], lat = xy[,2])
# dim(new_data)
# 
# #ATENCION!!!!!!hay que coger 'Fraxinus excelsior subsp. excelsior' y  'Fraxinus excelsior L.'
# # Guardar el nuevo conjunto de datos único en un archivo CSV
# write.csv(new_data, "FRESNO_unique.csv", row.names = FALSE)
# 
# # Visualización del raster y los puntos
# plot(TWI, ext = c(-2, 0, 37.5, 38.7))
# temp <- terra::vect(new_data, geom = c('lon', 'lat'), crs = 'EPSG:4326')
# plot(temp, col = 'black', pch = 19, cex = 0.4, add = TRUE)

###############################################################################################
###############################################################################################
# modificamos la columna "species" para que solo quede FRAXINUS EXCELSIOR L.
###############################################################################################
###############################################################################################
# Cargar librerías necesarias
library(dplyr)

# Cargar la tabla "FRESNO_unique.csvi"
# Nota: Si es un archivo CSV, el delimitador es probablemente ",", pero puedes ajustar "sep" según sea necesario.
tabla_fresno <- read.csv("FRESNO_clean.csv", sep = ";", stringsAsFactors = FALSE)

# Verificar la estructura inicial de la tabla
str(data_clean)

# Reemplazar todos los valores de la columna 'species' por "Fraxinus excelsior L."
data_clean <- data_clean %>%
  mutate(species = "Fraxinus excelsior L.")

# Guardar la tabla modificada como un nuevo archivo CSV
write.csv(data_clean, "FRESNO_unique_modified.csv", row.names = FALSE)

###############################################################################################
###############################################################################################
#  cogiendo los puntos que estan dentro de un shapefile madrid
###############################################################################################
###############################################################################################
# data_clean<- read.csv("FRESNO_unique_modified.csv", sep = ",", stringsAsFactors = FALSE)
# madrid <- vect('vect/recintos_autonomicas_inspire_peninbal_etrs89.shp')
# 
# 
# 
# 
# 
# 
# 
# # Reproyectar los puntos al CRS del shapefile si es necesario
# if (crs(data_clean) != crs(madrid)) {
#   data_clean <- project(data_clean, crs(madrid))
# }
# 
# # Seleccionar los puntos que están dentro del shapefile
# LOS_MEJORES_PTS_ESTAN_EN_MADRID <- data_clean[madrid, ]
# 
# # Convertir el resultado a un dataframe
# puntos_dentro_df <- as.data.frame(puntos_dentro)
# plot(madrid, col = 'light gray', xlim = c(-5, -2.5), ylim = c(39.7, 41.5))
# plot(puntos_dentro, col = 'red', pch = 19, add = TRUE)
# 
# 
# 
# 
# # Guardar el nuevo conjunto de datos limpio en un archivo CSV
# write.csv(data, "FRESNO_clean.csv", row.names = FALSE)


###############################################################################################
###############################################################################################
data_clean<- read.csv("FRESNO_unique_modified.csv", sep = ",", stringsAsFactors = FALSE)
madrid_shape <- st_read("vect/recintos_autonomicas_inspire_peninbal_etrs89.shp")

# 2. Convertir los puntos del CSV en un objeto espacial (sf)
# Especificamos que las coordenadas están en columnas 'lon' y 'lat', y usamos CRS WGS84 (EPSG:4326)
puntos_fresno <- st_as_sf(data_clean, coords = c("lon", "lat"), crs = 4326)
plot(madrid, col = 'light gray')
plot(puntos_fresno, col = 'red', pch = 19, add = TRUE)


# Transformar los puntos al CRS del shapefile si es necesario
puntos_fresno <- st_transform(puntos_fresno, crs = st_crs(madrid_shape))

# 5. Filtrar los puntos que están dentro del polígono de Madrid
puntos_dentro_madrid <- st_filter(puntos_fresno, madrid_shape)

# 6. Guardar los puntos filtrados en un nuevo archivo CSV ()

write.csv(puntos_dentro_madrid, "FRESNO_dentro_Madrid.csv", row.names = FALSE)
# Guardar los puntos como un shapefile
st_write(puntos_dentro_madrid, "FRESNO_dentro_Madrid_points.shp", driver = "ESRI Shapefile")

################################################################################


