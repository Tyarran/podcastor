let defaultString = (valueOption, default) => {
  switch valueOption {
  | Some(value) => value
  | None => default
  }
}
