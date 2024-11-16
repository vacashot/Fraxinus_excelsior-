#SCRIPT PARA EL BUFFER  RIOS####################################################
#El script crea un buffer de 100m y despues los agrega
################################################################################

rm(list = ls()) # Borramos todos los objetos que est?n creados
library(terra)
library(sf)
library(dplyr)
################################################################################
# buffer de embalses
################################################################################
# Configuración del directorio de trabajo
setwd("C:/Users/vacas/Desktop/master geoinformatica/ASIGNATURAS/Modelizacion/FRESNO")  # Cambia esto por la ruta de tu directorio de trabajo
getwd() # para saber en que directorio estoy trabajando

# Cargar la capa vectorial de ríos (formato shapefile, GeoJSON, etc.)
embalses <- st_read("vect/MASAS_EMBALSES_MADRID.shp") # Cambia el nombre del archivo a tu capa

# Verificar el sistema de referencia de coordenadas (CRS)
print(st_crs(embalses))

# Asegurarse de que el CRS sea adecuado para mediciones en metros
# Si es necesario, reproyectar (por ejemplo, a EPSG:25830 para España)
if (st_crs(rios)$units_gdal != "metre") {
  embalses <- st_transform(embalses, crs = 25830) # Cambia a un CRS métrico apropiado
}

# Crear un buffer de 100 metros
buffer_100m <- st_buffer(embalses, dist = 100)

# Unir los buffers en una sola capa
buffer_union <- st_union(buffer_100m)

# Guardar el resultado en un nuevo archivo (opcional)
st_write(buffer_union, "buffer_embalses_union.shp")

# Visualizar el resultado (opcional)
plot(st_geometry(buffer_union), col = "lightblue", main = "Buffer de 100m de Embalses")
################################################################################
################################################################################
# buffer de rios
################################################################################
################################################################################
# Cargar la capa vectorial de ríos (formato shapefile, GeoJSON, etc.)
rios <- st_read("vect/MASAS_rios_MADRID.shp") # Cambia el nombre del archivo a tu capa

# Verificar el sistema de referencia de coordenadas (CRS)
print(st_crs(rios))

# Asegurarse de que el CRS sea adecuado para mediciones en metros
# Si es necesario, reproyectar (por ejemplo, a EPSG:25830 para España)
if (st_crs(rios)$units_gdal != "metre") {
  rios <- st_transform(rios, crs = 25830) # Cambia a un CRS métrico apropiado
}

# Crear un buffer de 100 metros
buffer_100m <- st_buffer(rios, dist = 100)

# Unir los buffers en una sola capa
buffer_union <- st_union(buffer_100m)

# Guardar el resultado en un nuevo archivo (opcional)
st_write(buffer_union, "buffer_rios_union.shp")

# Visualizar el resultado (opcional)
plot(st_geometry(buffer_union), col = "lightblue", main = "Buffer de 100m de rios")
################################################################################
################################################################################
# union buffer rios + embalses
################################################################################
################################################################################
# Cargar las capas buffer
buffer_embalses <- st_read("buffer_embalses_union.shp") # Carga la capa de embalses
buffer_rios <- st_read("buffer_rios_union.shp") # Carga la capa de ríos

# Verificar y asegurarse de que ambas capas tengan el mismo CRS
if (st_crs(buffer_embalses) != st_crs(buffer_rios)) {
  buffer_rios <- st_transform(buffer_rios, crs = st_crs(buffer_embalses))
}

# Unir ambas capas en una sola
buffer_combined <- st_union(buffer_embalses, buffer_rios)

# Opcional: Guardar la capa combinada en un nuevo archivo
st_write(buffer_combined, "buffer_combined_union.shp")

# Visualizar la capa resultante (opcional)
plot(st_geometry(buffer_combined), col = "lightblue", main = "Unión de Buffers de Ríos y Embalses")

################################################################################
################################################################################
# CONVERSION DE EL BUFFER (RIOS+EMBALSES) A RASTER binario 
################################################################################
################################################################################

# Define las rutas de entrada y salida
buffer_file <- "buffer_combined_union.shp"  # Shapefile del buffer combinado
base_raster_file <- "bio/world_bio1.asc"   # Raster base como referencia
output_raster <- "buffer_rasterized.tif"   # Archivo raster de salida

# Cargar los datos
buffer_union <- vect(buffer_file)          # Shapefile del buffer
base_raster <- rast(base_raster_file)      # Raster base

# Verificar y reproyectar el buffer si el CRS no coincide con el raster base
if (crs(buffer_union) != crs(base_raster)) {
  buffer_union <- project(buffer_union, crs(base_raster))
}

# Ajustar la extensión del raster base para incluir completamente el buffer
ext(base_raster) <- ext(buffer_union)

# Rasterizar el buffer: Asignar valores 1 (presencia) y 0 (ausencia)
rasterized_buffer <- rasterize(buffer_union, base_raster, field = NA, background = 0)
values(rasterized_buffer)[!is.na(values(rasterized_buffer))] <- 1  # Presencia = 1

# Guardar el raster resultante
writeRaster(rasterized_buffer, output_raster, overwrite = TRUE)
######################paso 2 convertir a binario los na a cero##################
# Cargar el raster
input_raster <- "buffer_rasterized.tif"  # Cambia por la ruta de tu raster
output_raster <- "buffer_rasterized_0_1.tif"  # Cambia por la ruta donde guardarás el raster corregido

# Leer el raster
raster_data <- rast(input_raster)

# Reemplazar valores NA con 0
raster_data[is.na(raster_data)] <- 0

# Guardar el nuevo raster con los valores NA reemplazados por 0
writeRaster(raster_data, output_raster, overwrite = TRUE)

# Mensaje de éxito
cat("Raster procesado y guardado en:", output_raster, "\n")

############paso 3 convertimos unos a ceros y ceros a unos##################################

# Cargar el raster binario
input_raster <- "buffer_rasterized_0_1.tif"  # Cambia por la ruta de tu raster binario
output_raster <- "buffer_rasterized_0_1_ok_ok_ok_ok.tif"  # Ruta para guardar el raster modificado

# Leer el raster
binary_raster <- rast(input_raster)

# Verificar que sea binario (opcional)
unique_values <- unique(values(binary_raster))
if (!all(unique_values %in% c(0, 1, NA))) {
  stop("El raster no es binario (contiene valores distintos de 0, 1 o NA).")
}

# Intercambiar valores: 1 -> 0 y 0 -> 1
binary_raster[binary_raster == 1] <- -1  # Temporalmente asignar -1 para evitar conflictos
binary_raster[binary_raster == 0] <- 1
binary_raster[binary_raster == -1] <- 0

# Guardar el raster modificado
writeRaster(binary_raster, output_raster, overwrite = TRUE)

# Mensaje de éxito
cat("Raster procesado correctamente y guardado en:", output_raster, "\n")
################################################################################
#paso 5 recortamos el raster binario del buffer por la capa shp de madrid
################################################################################

# Define las rutas de entrada y salida
raster_file <- "buffer_rasterized_0_1_ok_ok_ok_ok.tif"  # Ruta del raster
shapefile <- "vect/recintos_autonomicas_inspire_peninbal_etrs89.shp"  # Ruta del shapefile de la Comunidad de Madrid
output_raster <- "buffer_rasterized_cortado.tif"  # Archivo raster de salida

# Cargar el raster y el shapefile
raster_data <- rast(raster_file)
madrid_shape <- vect(shapefile)



# Reproyectar el shapefile si no coincide con el CRS del raster
if (crs(madrid_shape) != crs(raster_data)) {
  madrid_shape <- project(madrid_shape, crs(raster_data))
}

# Recortar el raster usando el shapefile de Madrid
raster_cortado <- crop(raster_data, madrid_shape)  # Ajustar extensión
raster_cortado <- mask(raster_cortado, madrid_shape)  # Aplicar máscara para recorte preciso

# Guardar el raster resultante
writeRaster(raster_cortado, output_raster, overwrite = TRUE)







################################################################################
#paso 6 convertimos  EL TIF EN ASC
################################################################################
# Define el archivo de entrada y el directorio de salida
input_file <- "buffer_rasterized_cortado.tif"  # Cambia por el nombre de tu archivo .tif
output_file <- "buffer_rasterized_cortado.asc"  # Cambia la ruta y nombre si es necesario

# Cargar el archivo GeoTIFF
raster_data <- rast(input_file)

# Guardar el archivo como ASCII
writeRaster(raster_data, filename = output_file, overwrite = TRUE)

# Mensaje de éxito
cat("Archivo convertido correctamente a formato ASCII como:", output_file, "\n")

################################################################################
################################################################################












