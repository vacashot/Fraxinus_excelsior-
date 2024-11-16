################################################################################
################################################################################
#SCRIPT PARA CONVERTIR .geotiff ---> .asc EN BATH

# convierte todos los archivos tiff de una carpeta en .asc de una tacada
################################################################################
################################################################################
rm(list = ls()) # Borramos todos los objetos que est?n creados

# Cargar la librería
library(terra)

# Define el directorio de entrada y salida
 input_dir <- "C:/Users/vacas/Desktop/master geoinformatica/ASIGNATURAS/Modelizacion/FRESNO/rast"
 output_dir <- "C:/Users/vacas/Desktop/master geoinformatica/ASIGNATURAS/Modelizacion/FRESNO/SALIDAS_CONVERSION"

# Lista de archivos .tif en el directorio de entrada
tif_files <- list.files(input_dir, pattern = "\\.tif$", full.names = TRUE)
tif_files

# Iterar sobre cada archivo .tif y convertirlo a .asc
for (file in tif_files) {
  # Cargar el archivo GeoTIFF
  raster_data <- rast(file)
  
  # Crear el nombre de archivo de salida reemplazando la extensión
  output_file <- file.path(output_dir, paste0(tools::file_path_sans_ext(basename(file)), ".asc"))
  
  # Guardar el raster en formato .asc
  writeRaster(raster_data, filename = output_file, overwrite = TRUE)
  
  cat("Archivo convertido:", output_file, "\n")
}

asc_files <- list.files(output_dir, pattern = "\\.asc$", full.names = TRUE)
asc_files
################################################################################
################################################################################
#SCRIPT PARA CONVERTIR .geotiff ---> .asc  (ARCHIVO INDIVIDUAL)

# convierte UN  archivos tiff en .asc 
################################################################################
################################################################################
# Cargar la librería necesaria
library(terra)

# Define el archivo de entrada y el directorio de salida
input_file <- "C:/Users/vacas/Desktop/master geoinformatica/ASIGNATURAS/Modelizacion/FRESNO/rast/archivo.tif"  # Cambia por el nombre de tu archivo .tif
output_file <- "C:/Users/vacas/Desktop/master geoinformatica/ASIGNATURAS/Modelizacion/FRESNO/SALIDAS_CONVERSION/archivo.asc"  # Cambia la ruta y nombre si es necesario

# Cargar el archivo GeoTIFF
raster_data <- rast(input_file)

# Guardar el archivo como ASCII
writeRaster(raster_data, filename = output_file, overwrite = TRUE)

# Mensaje de éxito
cat("Archivo convertido correctamente a formato ASCII como:", output_file, "\n")
