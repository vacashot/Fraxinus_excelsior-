 # **Modelización espacial del Fresno común en Madrid**

Este proyecto analiza la distribución potencial del **Fraxinus excelsior L. subsp. excelsior** en la Comunidad de Madrid mediante el modelo BIOCLIM, integrando variables bioclimáticas y geográficas. El repositorio incluye los scripts, datos y resultados de este trabajo.

## **Resumen**
Se utilizó el algoritmo BIOCLIM para identificar áreas favorables para el fresno común en Madrid. Este análisis se realizó a partir de:
- **Variables bioclimáticas**: Datos como temperatura media anual, rango de temperaturas y precipitaciones (obtenidos de WorldClim).
- **Variables geográficas**: Índice Topográfico de Humedad (TWI), Modelo Digital de Elevación (MDT) y buffer de proximidad a ríos y masas de agua.

### **Resultados**
- Las áreas más favorables se concentran en el norte y noroeste de Madrid, en zonas húmedas y montañosas.
- Limitaciones: La resolución de 1 km² de las variables climáticas afecta la capacidad para identificar microhábitats específicos.

## **Estructura del proyecto**
- **`scripts/`**: Scripts en R utilizados para modelizar.
- **`data/`**: Datos bioclimáticos y geográficos procesados.
- **`results/`**: Mapas y gráficos generados.

## **Requisitos**
- **Software**: R y librerías como `dismo`, `raster`, y `sp`.
- **Datos adicionales**: Descargados de [WorldClim](https://worldclim.org) y [GBIF](https://doi.org/10.15468/dl.rb9zb7).

## **Cómo ejecutar**
1. Clona este repositorio:  
   ```bash
   git clone https://github.com/vacashot/Fraxinus_excelsior.git
   cd Fraxinus_excelsior
   ```
2. Instala las dependencias en R.
3. Ejecuta el script principal:  
   ```R
   source("scripts/main_model.R")
   ```

## **Instrucciones para añadir imágenes**
1. Guarda las imágenes en la carpeta `images/` de tu repositorio.
2. En el archivo Markdown, usa la siguiente sintaxis para insertar imágenes:  
   ```markdown
   ![Descripción de la imagen](images/nombre_imagen.png)
   ```
   Ejemplo:  
   ```markdown
   ![Mapa de distribución del Fresno](images/mapa_fresno.png)
   ```

## **Referencias**
- **GBIF.org**: [Descarga de ocurrencias](https://doi.org/10.15468/dl.rb9zb7).
- **WorldClim**: [Datos bioclimáticos](https://worldclim.org).
