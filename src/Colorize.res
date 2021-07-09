type colors = Red | White | Yellow
type modifiers = Bold

let createElement = (~color, ~children=list{}, ()) => {
  let colored = Belt.List.map(children, child => {
    switch color {
    | Red => Bindings.Chalk.red(child)
    | White => Bindings.Chalk.white(child)
    | Yellow => Bindings.Chalk.yellow(child)
    }
  })
  let result = Belt.List.reduce(colored->Belt.List.reverse, "", (item, acc) => {
    acc ++ item
  })
  result
}
