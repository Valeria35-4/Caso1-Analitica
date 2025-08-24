# Caso1-Analitica
Caso 1 

# Web Analytics – Quality Alloys, Inc.

Este repositorio corresponde al caso **Web Analytics at Quality Alloys, Inc. (CU44)** presentado en el curso de Analítica de Negocios de la Pontificia Universidad Javeriana.  

Contiene los datos, scripts y reportes asociados al análisis del sitio web corporativo de **Quality Alloys, Inc.**, una empresa distribuidora de aleaciones industriales en Estados Unidos.  

---

## Resumen  

Quality Alloys (QA) es un distribuidor de aleaciones refractarias y especiales que en 2008 decidió ampliar su estrategia de mercadeo creando un sitio web corporativo. El objetivo del caso es evaluar el impacto de la presencia digital de QA en variables de negocio como **visitas web, solicitudes de información, ingresos, ganancias y libras vendidas**.  

El análisis busca responder preguntas clave como:  
- ¿Cuántas personas visitan el sitio web y cómo llegan a él?  
- ¿El sitio web genera interés que se traduzca en ventas reales?  
- ¿Las promociones tradicionales impulsan el tráfico web y las ventas incrementales?  
- ¿Qué relación existe entre métricas web y resultados financieros?  

Este trabajo replica y extiende los análisis cuantitativos mediante **R**, integrando datos de Google Analytics y registros financieros de QA para evaluar correlaciones, tendencias y efectos de la promoción.  

---

## Estructura del Repositorio  

### Carpeta **Document**
- **Web_Analytics.en.es.pdf**: Documento del caso original traducido al español, con instrucciones y contexto empresarial.  
- **Reporte_Web_Analytics.pdf**: Reporte generado a partir del análisis en R (ejecutivo + resultados cuantitativos).  

### Carpeta **Scripts**
El análisis se realiza en **R (versión ≥ 4.0.0)**. El script principal es:  

- **analysis_QA.R**: Script que contiene el flujo completo del análisis:  
  1. **Lectura y preparación de datos** desde `financials.xls` y `Weekly Visits.xls`.  
  2. **Unión de métricas web y financieras** mediante claves de semanas.  
  3. **Limpieza y transformación** de variables para análisis.  
  4. **Cálculo de correlaciones** entre métricas (ingresos, visitas, libras vendidas, etc.).  
  5. **Visualización de resultados**, incluyendo:  
     - Serie de tiempo de *Profit*.  
     - Barras comparativas de visitas por canal.  
     - Diagramas de dispersión entre métricas (ej. ingresos vs. libras vendidas, ingresos vs. visitas únicas). 
  6. **Analisis** 

 

### Carpeta **Data**
- `financials.xls`: Datos financieros semanales de QA (Revenue, Profit, Lbs. Sold, Inquiries).  
- `Weekly Visits.xls`: Datos de visitas web capturados en Google Analytics, desagregados por canal.  

---

## Notas de Uso  

- Antes de ejecutar los scripts, configure el **directorio de trabajo** en la carpeta `Proyecto`.  
- Instale los paquetes requeridos en R:  
  ```r
  install.packages(c("readxl", "dplyr", "ggplot2"))
  ```  
- El tiempo de ejecución dependerá de las características de su máquina.  

---

## Autores  

Valeria Garcia Torres
Andres Camilo Franco Rincon 
Juan Pablo