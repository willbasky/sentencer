# sentencer

Utility to translate each sentence of a text to source/target
It use [translate-shell](https://github.com/soimort/translate-shell) under hood to communicate with Google Translate Api.

## Example

[Input](./content/sample_tren.txt):
```text
TREN De Alejandro Dolina
(del libro Bar del Infierno)
”El tren pasa solo dos veces por año. Llega a la madrugada y se detiene apeas unos segundos. Es un tren enorme, más largo que la distancia entre las estaciones: cuando los primeros vagones llegan a un pueblo, los últimos aún están en el anterior.
```
[Output](./content/hs_result_tren.txt):
```text
TREN De Alejandro Dolina
ПОЕЗД Алехандро Долина

(del libro Bar del Infierno)
(из книги Адский бар)

”El tren pasa solo dos veces por año.
«Поезд ходит только два раза в год.

Llega a la madrugada y se detiene apeas unos segundos.
Он прибывает на рассвете и останавливается всего на несколько секунд.

Es un tren enorme, más largo que la distancia entre las estaciones: cuando los primeros vagones llegan a un pueblo, los últimos aún están en el anterior.
Это огромный поезд, длиннее, чем расстояние между станциями: когда первые вагоны прибывают в город, последние еще остаются в предыдущем.
```

## How to use

1. Modify [config file](content.toml) directory of input file and name of file.
   The configuration via Toml implemented for Haskell, Go and Rust versions.
   The paths in other languages hardcoded in sources.

2. Run language-specific command:

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

- Go

```shell
go run sentencer/gsentencer
```

- Rust

```shell
cargo run
```

## Roadmap

- [x] Haskell
- [x] PureScript
- [x] Ocaml
- [x] Go
- [x] Rust
- [ ] Python
- [ ] TypeScript
- [ ] Kotlin
