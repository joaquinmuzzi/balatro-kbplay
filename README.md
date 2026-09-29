# kbplay — Balatro con teclado

Mod para jugar Balatro entero con el teclado, sin tocar el mouse.

> Estado: **esqueleto**. La estructura y las acciones básicas están listas; falta probarlo a fondo en el juego.

## Instalación

Solo necesita [lovely](https://github.com/ethangreen-dev/lovely-injector) (Steamodded es opcional).

Copiá (o cloná) esta carpeta en `%AppData%\Balatro\Mods\kbplay`.

Para desarrollar, conviene un *junction* desde la carpeta de Mods al repo, así cada cambio se ve al reiniciar el juego:

```bat
mklink /J "%AppData%\Balatro\Mods\kbplay" "C:\ruta\al\repo"
```

## Cómo se juega

Cada pantalla tiene **zonas** (mano, jokers, consumibles, tienda, sobre). `Tab` cambia de zona, y los números eligen cartas dentro de la zona activa.

| Tecla | Acción |
|---|---|
| `1`–`9`, `0` | marcar/desmarcar la carta N de la zona activa |
| `Tab` / `Shift+Tab` | zona siguiente / anterior |
| `Enter` | acción principal: jugar mano, elegir ciega, cobrar, comprar, usar, elegir del sobre |
| `Shift+Enter` | comprar y usar (consumibles en la tienda) |
| `D` | descartar |
| `Supr` | vender joker/consumible seleccionado |
| `Backspace` | desmarcar todo |
| `Shift+←/→` | mover la carta seleccionada |
| `Z` / `X` | ordenar la mano por número / palo |
| `K` | saltar ciega / saltar sobre |
| `R` | reroll de tienda / reroll de jefe (tocar, no mantener: mantener `R` reinicia la partida en el juego base) |
| `N` | salir de la tienda (siguiente ronda) |

`Esc` y los menús siguen funcionando como en el juego base.

### Cambiar teclas

Creá `%AppData%\Balatro\kbplay-keys.lua`:

```lua
return {
  discard = "q",
  sell = "ctrl+backspace",
  sort_suit = false, -- desactiva la acción
}
```

Los nombres de acciones están en [`src/keymap.lua`](src/keymap.lua); los de teclas son los de [LÖVE](https://love2d.org/wiki/KeyConstant).

## Cómo funciona

- [`lovely/`](lovely): registra los archivos de `src/` como módulos y carga el mod después de `G = Game()`.
- [`src/init.lua`](src/init.lua): envuelve `Controller:key_press_update`. Si la tecla es nuestra, la maneja; si no, la deja pasar al juego.
- [`src/ui.lua`](src/ui.lua): en vez de reimplementar reglas, **aprieta los botones del propio juego** solo cuando están habilitados. Así se respetan el dinero, los jefes, los bloqueos y otros mods.
- [`src/zones.lua`](src/zones.lua): zonas de cartas, selección, tooltips y reordenar.
- [`src/states.lua`](src/states.lua): qué hace cada tecla en cada pantalla (`G.STATE`).
- [`src/actions.lua`](src/actions.lua): las acciones en sí.

Si algo falla dentro del mod, el error va a la consola de lovely y la tecla pasa al juego, así que la partida no se cae.

## Pendiente

- [ ] Probar cada pantalla en el juego (sobre todo el reroll de jefe y saltar ciega)
- [ ] Indicador visual permanente de la zona activa y de los números sobre las cartas
- [ ] Navegar con flechas, además de los números
- [ ] Menú principal, nueva partida, pantalla de fin de partida
- [ ] Ver mazo / info de la partida
- [ ] Compatibilidad con HandyBalatro y Steamodded

## Créditos

Idea inspirada en [Typist](https://github.com/kasimeka/balatro-typist-mod) de kasimeka. No se reutilizó su código.
