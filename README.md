# Wordle en Ensamblador ARM

¡Bienvenido al proyecto **Wordle en Ensamblador ARM**! Este programa es una implementación del popular juego **Wordle**, desarrollado en lenguaje ensamblador para la arquitectura ARM. 

El proyecto fue realizado como parte del trabajo práctico de la materia **Organización del Computador** de la carrera **Tecnicatura en Informática** de la **Universidad Nacional General Sarmiento (UNGS)**, Argentina.

El juego toma una palabra aleatoria de un archivo que contiene una lista de palabras previamente definidas, lo que también involucra el trabajo con acceso a archivos.

---

## 📋 ¿Qué es Wordle?

**Wordle** es un juego de adivinanzas donde el objetivo es descubrir una palabra secreta de cinco letras en un número limitado de intentos.

### Reglas:
1. El jugador ingresa una palabra de 5 letras.
2. El programa compara la palabra ingresada con la palabra secreta y proporciona pistas:
   - **🟩 Verde:** La letra está en la palabra secreta **y** en la posición correcta.
   - **🟨 Amarillo:** La letra está en la palabra secreta, pero en una posición diferente.
   - **⬜ Gris:** La letra no está en la palabra secreta.
3. El jugador tiene hasta **6 intentos** para adivinar la palabra.
4. El juego termina cuando el jugador adivina la palabra secreta o se agotan los intentos.

---

## 🛠️ Detalles Técnicos

### Arquitectura:
- **Procesador:** ARM (compatible con Raspberry Pi o emuladores como QEMU).
- **Sistema Operativo:** Raspbian o equivalente.

### Lenguaje:
- Ensamblador ARM (ARMv7).

### Características del proyecto:
- Comparación de cadenas para validar intentos.
- Simulación de pistas mediante texto en la consola.
- Gestión de intentos y validación de palabras.
- Acceso a archivos para seleccionar palabras aleatorias de un conjunto predefinido.
- Almacenamiento de palabras estáticas en memoria.

---

## 🎓 Sobre el Proyecto

Este proyecto fue realizado como parte de un trabajo práctico para la materia **Organización del Computador**, en la carrera **Tecnicatura en Informática** en la **Universidad Nacional General Sarmiento (UNGS)** de Argentina.

El objetivo principal es entender y aplicar conceptos de arquitectura de computadores a través de la implementación de un juego simple en ensamblador, utilizando la arquitectura ARM.

---

## ✍️ Autores

- **Joaquín Vásquez**  
  GitHub: [joaquinvasquez](https://github.com/joaquinvasquez)  
  Estudiante de la Tecnicatura en Informática  
  **Universidad Nacional General Sarmiento (UNGS)**

- **Ezequiel Sortano**  
  GitHub: [SortanoEzequiel](https://github.com/SortanoEzequiel)  
  Estudiante de la Tecnicatura en Informática  
  **Universidad Nacional General Sarmiento (UNGS)**
