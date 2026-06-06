# Guia Visual Veterinaria DAM

## Objetivo visual

La interfaz debe comunicar tres ideas en todo momento:
- Profesionalismo clinico
- Cercania y cuidado animal
- Claridad operativa para personal de recepcion y consulta

## Paleta oficial

### Colores base

- `primary`: `#0E7490` (teal clinico)
- `primaryLight`: `#67AFC2`
- `primaryDark`: `#0A556A`
- `secondary`: `#4A7C59` (verde salud)
- `secondaryLight`: `#7FA88A`
- `secondaryDark`: `#355A41`
- `accent`: `#E58F65` (llamados de atencion suaves)

### Neutros y soporte

- `background`: `#F3F7F8`
- `surface`: `#FFFFFF`
- `surfaceAlt`: `#E9F0F2`
- `textPrimary`: `#1F2B33`
- `textSecondary`: `#5A6A73`
- `border`: `#D0DDE1`

### Estados

- `success`: `#2E7D32`
- `warning`: `#B7791F`
- `error`: `#C62828`
- `info`: `#2563EB`

## Reglas de color

1. `primary` para acciones primarias y elementos clave de navegacion.
2. `secondary` para estados estables de salud o categorias secundarias.
3. `accent` solo para resaltar CTA no destructivos o metricas destacadas.
4. `error` exclusivo para fallas, validaciones y alertas clinicas.
5. Texto principal siempre en `textPrimary` sobre `surface` o `background`.

## Reglas tipograficas

1. Jerarquia minima:
   - Titulos de pantalla: `titleLarge`
   - Titulos de seccion/card: `titleMedium`
   - Contenido principal: `bodyLarge`
   - Soporte o notas: `bodyMedium`
2. Evitar bloques largos en mayusculas.
3. Limitar lineas de texto clave a 2 lineas maximo en cards.

## Reglas de componentes

1. Cards:
   - Fondo `surface`
   - Borde sutil `border`
   - Radio 16
2. Inputs:
   - Fondo `surface`
   - Radio 12
   - Borde `border`, foco `primary`
3. Boton primario:
   - Fondo `primary`
   - Texto blanco
   - Alto minimo 46
4. Espaciado:
   - Margenes de pantalla: 16
   - Separacion entre bloques: 12-16

## Reglas de UX

1. Cada pantalla debe tener estado vacio explicativo y accion sugerida.
2. No depender solo del color para comunicar estado; usar texto o icono.
3. Errores de API deben verse como mensaje amigable y accion reintentar.
4. Priorizar lectura rapida en contexto clinico: menos ruido, mas datos utiles.

## Implementacion en codigo

La implementacion centralizada se encuentra en:
- `lib/core/theme/app_palette.dart`
- `lib/core/theme/app_theme.dart`

Todas las pantallas nuevas deben reutilizar estos tokens y no declarar colores hardcodeados, excepto casos excepcionales de visualizacion (ejemplo: graficos de reporteria con leyenda propia).
