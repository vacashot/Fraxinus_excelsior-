################################################################################
# SCRIPT PARA RECORTAR RASTER POR CAPA SHAPEFILE
################################################################################

# Cargar las librerías
library(terra)
library(sf)

# Ruta al shapefile de Madrid
shapefile_path <- "C:/Users/vacas/Desktop/master geoinformatica/ASIGNATURAS/Modelizacion/FRESNO/vect/recintos_autonomicas_inspire_peninbal_etrs89.shp"


# Directorios de entrada y salida
input_dir <- "C:/Users/vacas/Desktop/master geoinformatica/ASIGNATURAS/Modelizacion/FRESNO/bio"
output_dir <- "C:/Users/vacas/Desktop/master geoinformatica/ASIGNATURAS/Modelizacion/FRESNO/RECORTES_MADRID"

# Cargar el shapefile
madrid_shp <- st_read(shapefile_path)

#comprobar crs
crs(madrid_shp)


# Lista de archivos .asc en el directorio de entrada
asc_files <- list.files(input_dir, pattern = "\\.asc$", full.names = TRUE)
asc_files

# Iterar sobre cada archivo .asc
for (asc_file in asc_files) {
  # Cargar el archivo .asc
  raster_data <- rast(asc_file)
  
  # Verificar y proyectar si es necesario
  if (!st_crs(madrid_shp) == crs(raster_data)) {
    cat("Proyectando el archivo raster para que coincida con el shapefile...\n")
    raster_data <- project(raster_data, st_crs(madrid_shp)$proj4string)
  }
  #Extender el raster para que cubra completamente el shapefile
  raster_data <- extend(raster_data, ext(vect(madrid_shp)))
  
  # Recortar el raster usando el shapefile
  cropped_raster <- crop(raster_data, vect(madrid_shp))
  masked_raster <- mask(cropped_raster, vect(madrid_shp))
  
  # Crear el nombre de archivo de salida
  output_file <- file.path(output_dir, paste0(tools::file_path_sans_ext(basename(asc_file)), "_cropped.asc"))
  
  # Guardar el archivo recortado
  writeRaster(masked_raster, filename = output_file, overwrite = TRUE)
  
  cat("Archivo recortado y guardado en:", output_file, "\n")
