# EcoSync — Frontend

<div align="center">
  <img src="static/logo.avif" alt="EcoSync Logo" width="120" />
  <h1>EcoSync: Limpieza Digital para un Planeta Sostenible</h1>
  <p><b>Optimiza tu espacio, reduce tu huella y combate la contaminación invisible.</b></p>
</div>

---

## Sobre el Proyecto

EcoSync es una plataforma integral diseñada para combatir la contaminación digital invisible. Nuestra aplicación escanea tu huella a través de múltiples entornos y servicios, detectando basura residual, archivos "muertos", repositorios archivados y recursos duplicados.

### Nuestra Misión y Visión

**Misión:** Capacitar y empoderar a los usuarios sobre el impacto medioambiental que genera el almacenamiento inútil. Proveemos herramientas intuitivas y seguras para erradicar la "basura digital", reduciendo activamente nuestra huella de carbono digital personal y empresarial.

**Visión:** Convertirnos en el estándar definitivo para la concientización ecológica de datos a nivel mundial. Visualizamos un internet más liviano, ordenado y sostenible.

---

## Módulos de Limpieza e Inteligencia

La plataforma cuenta con cuatro fases de análisis avanzado:

![EcoSync Hub](static/docs/Captura%20de%20pantalla%202026-03-31%20122639.png)


### 1. Gestión de Repositorios (GitHub)
Analiza repositorios inactivos y forks obsoletos en tu perfil de desarrollador.
![GitHub Scan](static/docs/Captura%20de%20pantalla%202026-03-31%20122526.png)

### 2. Optimización de Nube (Google Drive)
Identifica archivos duplicados y de gran tamaño que consumen energía en centros de datos.
![Drive Scan](static/docs/Captura%20de%20pantalla%202026-03-31%20122546.png)

### 3. Almacenamiento Local (PC)
Localiza instaladores, temporales y cachés residuales directamente en tu disco duro.
![Local Scan](static/docs/Captura%20de%20pantalla%202026-03-31%20122558.png)

### 4. Cazador de Cuentas (OSINT)
Rastrea perfiles asociados a tu identidad digital para facilitar el derecho al olvido.
![OSINT Radar](static/docs/Captura%20de%20pantalla%202026-03-31%20122619.png)

---

## Funcionamiento y Flujo de Usuario

La plataforma ha sido diseñada bajo una arquitectura de micro-interacciones fluida, utilizando una interfaz minimalista (Glassmorphism) para centrar la atención en la toma de decisiones ecológicas. El proceso se divide en cuatro fases críticas:

#### 1. Autenticación y Configuración de Reglas
El usuario selecciona el entorno de análisis (Google Drive, GitHub, PC Local o Cuentas). EcoSync gestiona la seguridad mediante flujos de **OAuth2** (permisos temporales y seguros) o el ingreso de parámetros de escaneo específicos. En esta etapa, es posible definir umbrales de búsqueda, como la antigüedad del archivo o el tamaño mínimo de detección.

#### 2. Motor de Análisis de Impacto
Nuestro motor procesa los metadatos en tiempo real para clasificar la "basura digital". El análisis incluye la detección de:
*   **Repositorios Zombie:** Forks antiguos que no han recibido actualizaciones ni actividad del desarrollador.
*   **Cachés Residuales:** Archivos temporales ocultos que han quedado en el sistema tras la desinstalación de aplicaciones.
*   **Identidad Digital:** Rastreo de huellas en decenas de plataformas obsoletas que exigen mantenimiento energético de datos persistentes.

#### 3. Métricas Ecológicas Comparativas
Antes de proceder, los datos se transforman en **indicadores de impacto real** a través de un Dashboard dinámico. En lugar de simples estadísticas de disco, EcoSync muestra conversiones comprensibles del exceso energético:
*   Equivalencia en horas de iluminación mediante bombillas LED.
*   Cálculo del número de árboles necesarios para absorber el excedente de CO2 generado por tus archivos inactivos.
*   Comparativas de ahorro energético por GB eliminado mensualmente.

#### 4. Ejecución de Limpieza Inteligente y Segura
Mediante una ventana de revisión interactiva, el usuario valida los elementos a eliminar. La plataforma ofrece un sistema de control dual:
*   **Papelera Transitoria:** Envío seguro a la papelera del sistema para una posible recuperación.
*   **Destrucción Permanente:** Borrado directo de la infraestructura para maximizar el ahorro de espacio instantáneo. 
Cada acción de limpieza actualiza automáticamente tu récord global de mitigación climática en la plataforma.

### Demostración Visual
![EcoSync Demo](static/docs/recording.gif)

---

## Guía de Instalación Local

Para correr EcoSync-Front en tu servidor local:

1. **Instalar dependencias:** `npm install`
2. **Configurar .env:** Crear archivo con `PUBLIC_URL_API="http://localhost:8000"`
3. **Correr programa:** `npm run dev`

---

## Stack Tecnológico

- **Svelte 5 / SvelteKit:** Reactividad rápida con el sistema de Runes.
- **Tailwind CSS:** Interfaz adaptable con soporte Dark Mode.
- **Micro-animaciones:** Transiciones fluidas en el Dashboard.

---

<div align="center">
  <p>Desarrollado por el equipo de EcoSync.</p>
  <p><b>Hagamos del internet un lugar más verde.</b></p>
</div>
