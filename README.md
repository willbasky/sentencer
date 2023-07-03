# sentencer

Utility to translate each sentence of a text to source/target

## Example



[Input](./content/sample_tren.txt):
```text
”El tren pasa solo dos veces por año. Llega a la madrugada y se detiene apeas unos segundos. Es un tren enorme, más largo que la distancia entre las estaciones: cuando los primeros vagones llegan a un pueblo, los últimos aún están en el anterior.
```
[Output](./content/hs_result_tren.txt):
```text
”El tren pasa solo dos veces por año.
«Поезд ходит только два раза в год.

Llega a la madrugada y se detiene apeas unos segundos.
Он прибывает на рассвете и останавливается всего на несколько секунд.

Es un tren enorme, más largo que la distancia entre las estaciones: cuando los primeros vagones llegan a un pueblo, los últimos aún están en el anterior.
Это огромный поезд, длиннее, чем расстояние между станциями: когда первые вагоны прибывают в город, последние еще остаются в предыдущем.
```

## Roadmap

- [x] Haskell
- [x] PureScript
- [x] Ocaml
- [ ] Python
- [ ] TypeScript
- [ ] Rust
- [ ] Kotlin

## How to use

- Haskell

```shell
stuck run
```

- PureScript

```shell
spago run
```

- Ocaml

```shell
dune exec osentencer
```
