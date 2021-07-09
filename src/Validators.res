type raw
type reason = Missing | Required | Invalid

external toRaw: 'a => raw = "%identity"

let string = data => {
  Js.log(Js.typeof(data))
  switch Js.typeof(data) {
  | "string" => true
  | _ => false
  }
}

let int = data => {
  switch Js.typeof(data) {
  | "number" => true
  | _ => false
  }
}

let nullOrUndefined = data => {
  switch Js.typeof(data) {
  | "object" => Js.Nullable.return(data) === Js.Nullable.null ? true : false
  | "undefined" => true
  | _ => false
  }
}

module Field = {
  let valid = (~required=true, ~name, ~validator, data: Js.Dict.t<raw>) => {
    let validationResult = switch Js.Dict.get(data, name) {
    | Some(value) =>
      switch (validator(value), required) {
      | (true, _) => Ok(value)
      | (false, false) =>
        switch nullOrUndefined(value) {
        | false => Error(Invalid)
        | true => Ok(value)
        }
      | (false, true) => Error(Invalid)
      }
    | None => Error(Missing)
    }
    (name, validationResult)
  }

  let createElement = (~required=true, ~name, ~validator, ~children=list{}, ()) => {
    let _ = children
    valid(~required, ~name, ~validator)
  }
}

module Obj = {
  let createElement = (~children=list{}, ()) => {
    children
  }
}

let valid = (data, fields) => {
  let (valids, errors) = Belt.List.reduceReverse(fields, (Js.Dict.fromArray([]), list{}), (
    acc,
    field,
  ) => {
    let (fieldname, result) = field(data)
    let (acc_valids, acc_errors) = acc
    switch result {
    | Ok(value) => {
        Js.Dict.set(acc_valids, fieldname, value)
        (acc_valids, acc_errors)
      }
    | Error(reason) => (acc_valids, list{(fieldname, reason), ...acc_errors})
    }
  })
  switch Belt.List.length(errors) > 0 {
  | true => Error(errors->Belt.List.toArray)
  | false => Ok(valids)
  }
}
