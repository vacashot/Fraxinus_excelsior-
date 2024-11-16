################################################################################
################################################################################
#SCRIPT PARA ALINEAR Y PONER MISMA RESOLUCION A VARIOS RASTER
################################################################################
################################################################################
rm(list = ls()) # Borramos todos los objetos que est?n creados

# Cargar las librerías
library(dismo)
library(terra)
library(adehabitatHS)
library(sf)
library(ggplot2)
library(raster)
################################################################################
# Cambia esto por la ruta de tu directorio de trabajo
getwd() # para saber en que directorio estoy trabajando
setwd("C:/Users/vacas/Desktop/master geoinformatica/ASIGNATURAS/Modelizacion/FRESNO")  
getwd() # para saber en que directorio estoy trabajando

################################################################################
################################################################################
# 0. CARGAR DATOS PUNTOS DE FRESNO Y SHP DE MADRID
################################################################################
################################################################################
# Definir el sistema de coordenadas
epsg <- 'EPSG:4326'

# Cargar el shapefile del madrid
madrid_shp <- vect('vect/recintos_autonomicas_inspire_peninbal_etrs89.shp')

# Cargar los datos desde un archivo CSV
data <- read.csv("FRESNO_PUNTAZOS.csv")
head(data)

# Convertir los datos en un objeto espacial con coordenadas y sistema de referencia
temp <- terra::vect(data, geom=c('X', 'Y'), crs='EPSG:4326')

# Graficar el shapefile del mundo en color negro
plot(madrid_shp, col='gray')

# Graficar los puntos de 'data' (puntos de fresno) en color rojo sobre el mapa
plot(temp, col='red', pch=19, cex=0.1, add=TRUE)
################################################################################
################################################################################
# todos los raster a mismo crs extension y resolucion
################################################################################
################################################################################


# Cargar las variables climáticas (.asc)
bio1 <- raster("RECORTES_MADRID/world_bio1_cropped.asc")
bio2 <- raster("RECORTES_MADRID/world_bio2_cropped.asc")
bio6 <- raster("RECORTES_MADRID/world_bio6_cropped.asc")
bio12 <- raster("RECORTES_MADRID/world_bio12_cropped.asc")
bio14 <- raster("RECORTES_MADRID/world_bio14_cropped.asc")
bio16 <- raster("RECORTES_MADRID/world_bio16_cropped.asc")

# Cargar las variables geográficas
twi <- raster("SALIDAS_CONVERSION/twi_mad.asc")  # Índice TWI
mdt <- raster("SALIDAS_CONVERSION/MDT_MADRID_SIN_HUCOS_ETRS89.asc")  # Modelo Digital de Terreno
buffer_rivers <- raster("buffer_rasterized_cortado.asc")  # Buffer de ríos y masas de agua

################################################################################


reproject_if_needed <- function(raster, reference_crs) {
  if (as.character(crs(raster)) != as.character(reference_crs)) {
    raster <- projectRaster(raster, crs = reference_crs)
  }
  return(raster)
}

# Reproyectar todos los rásters
twi <- reproject_if_needed(twi, crs(bio1))
buffer_rivers <- reproject_if_needed(buffer_rivers, crs(bio1))
mdt <- reproject_if_needed(mdt, crs(bio1))


# Recortar a la extensión de bio1
twi <- crop(twi, extent(bio1))
buffer_river <- crop(buffer_rivers, extent(bio1))
mdt <- crop(mdt, extent(bio1))

# Alinear los rásters a bio1
twi_aligned <- resample(twi, bio1, method = "bilinear")
buffer_river_aligned <- resample(buffer_river, bio1, method = "ngb")  # ngb para datos binarios
mdt_aligned <- resample(mdt, bio1, method = "bilinear")

# Guardar los rásters alineados
writeRaster(twi_aligned, "RASTER_ALINEADOS/twi_aligned.asc", format = "ascii", overwrite = TRUE)
writeRaster(buffer_river_aligned, "RASTER_ALINEADOS/buffer_river_aligned.asc", format = "ascii", overwrite = TRUE)
writeRaster(mdt_aligned, "RASTER_ALINEADOS/mdt_aligned.asc", format = "ascii", overwrite = TRUE)

# Visualizar (opcional)
plot(bio1, main = "Raster de Referencia: bio1")
plot(twi_aligned, main = "Raster Alineado: TWI")
plot(buffer_river_aligned, main = "Raster Alineado: Buffer River")
plot(mdt_aligned, main = "Raster Alineado: MDT")
