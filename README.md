# 🌿 EcoSync

**EcoSync** es una plataforma integral diseñada para combatir la contaminación digital invisible. Nuestra aplicación escanea tu huella a través de múltiples entornos y servicios (Google Drive, GitHub, Almacenamiento Local de tu PC y Cuentas Fantasmas vía OSINT), detectando basura residual, archivos "muertos", repositorios archivados y recursos duplicados. 

EcoSync no solo te permite limpiar estos archivos para recuperar espacio de almacenamiento masivo, sino que estima con precisión el **CO₂ potencial al año** que ahorras al reducir la constante demanda energética y de enfriamiento que exiges a los gigantescos data centers globales.

---

## 🎯 Nuestra Misión y Visión

### 🚀 Misión
Capacitar y empoderar a los usuarios de tecnología sobre el impacto medioambiental que genera el almacenamiento en la nube y la retención de datos inútiles. Proveemos herramientas intuitivas y seguras para localizar y erradicar la "basura digital", reduciendo así, de forma proactiva, nuestra huella de carbono digital tanto a nivel personal como empresarial.

### 🔭 Visión
Convertirnos en el estándar definitivo para el mantenimiento y concientización ecológica de datos a nivel mundial. Visualizamos un internet más liviano, ordenado y sostenible, donde la innovación digital avance en perfecta armonía con la preservación de nuestro planeta.

---

## ⚙️ ¿Cómo funciona y cómo se usa?

La plataforma está diseñada con una interfaz minimalista, moderna (*Glassmorphism*) e intuitiva. Consta de cuatro fases:

1. **Autenticación y Reglas de Escaneo:** Seleccionas un módulo (Drive, Github, PC Local o Cuentas). Según lo requerido, EcoSync solicitará permisos temporales seguros (OAuth) o parámetros de usuario a escanear.
2. **Análisis de Impacto:** Nuestro motor clasifica los tiempos de inactividad, detecta repositorios "zombies" (Forks abandonados), cachés residuales y busca tus rastros en docenas de plataformas obsoletas.
3. **Métricas Ecológicas en la Vida Real:** Antes de eliminar, accederás a un *"Dashboard"* dinámico. Verás conversiones reales de la energía que malgastan tus archivos inactivos métricas comprensibles (Ej. horas de bombilla LED encendidas sin límite, cantidad de árboles requeridos para absorber tu excedente).
4. **Limpieza Inteligente y Segura:** Mediante nuestra ventana de revisión, puedes seleccionar múltiples elementos obsoletos. Podrás decidir si delegar el envío a una "papelera transitoria", o desencadenar una destrucción total. ¡Cada limpieza actualiza tu récord de mitigación climática!

---

## 💻 Guía de Instalación Local

Para correr **EcoSync-Front** en tu servidor local de pruebas, necesitarás tener instalado [Node.js](https://nodejs.org) (versión 18 o superior recomendada).

### Paso a paso:

**1. Clonar el repositorio**
Abre una terminal y clona este proyecto a tu entorno local:
```bash
git clone https://github.com/TuUsuario/EcoSync-Front.git
cd EcoSync-Front
```

**2. Instalar las dependencias**
Instala los paquetes (SvelteKit, Tailwind, Sonner, etc.) mediante NPM:
```bash
npm install
```

**3. Configurar Variables de Entorno**
En la raíz de tu proyecto, existe (o deberás crear) un archivo `.env`. Este debe contener la dirección que apunta a tu *backend* (API de Python/Node que maneja la lógica de procesamiento) para que se logre una conexión exitosa:
```env
PUBLIC_URL_API="http://localhost:8000" # URL donde escuches la API de tu EcoSync-Backend
```

**4. Levantar el entorno de Desarrollo**
Ejecuta Vite y SvelteKit para correr el Frontend con `Hot Module Replacement` (HMR):
```bash
npm run dev
```

**5. Uso Inicial / Primera Ejecución**
Abre tu navegador web y dirígete a `http://localhost:5173`. Navegando por la plataforma, usa el menú principal para ir probando los componentes de escaneo. Asegúrate de que el Backend general también esté operando paralelamente.

---

## 🛠 Stack Tecnológico y UI
* **Svelte 5 / SvelteKit:** Potencia un renderizado hiper-rápido optimizado bajo la nueva estructura y paradigma de "Runes" (`$state`, `$derived`, `@render`).
* **Tailwind CSS:** Experiencia de UI responsiva y nativamente empaquetada con compatibilidad total en `Dark Mode`, asegurando bajo consumo de poder luminoso si se visualiza en pantallas OLED.
* **Componentes Custom:** Sistema de alertas asíncronas optimizadas y UI de Dialogs con fondos reactivos borrosos.

---

<p align="center">
  <i>Desarrollado con el objetivo de restaurar el balance natural de nuestra nube pública.</i>
</p>
