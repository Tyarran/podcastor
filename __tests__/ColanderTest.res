open Jest
open Expect

describe("Test string validation", () => {
  test("js string", () => {
    let value = %raw(`"a string"`)
    expect(Colander.string(value)) |> toBe(true)
  })

  test("Js null", () => {
    let value = %raw(`null`)
    expect(Colander.string(value)) |> toBe(false)
  })

  test("Js undefined", () => {
    let value = %raw(`undefined`)
    expect(Colander.string(value)) |> toBe(false)
  })

  test("Js int", () => {
    let value = %raw(`42`)
    expect(Colander.string(value)) |> toBe(false)
  })

  test("Js object", () => {
    let value = %raw(`{"one": 1}`)
    expect(Colander.string(value)) |> toBe(false)
  })
})

describe("Test int validation", () => {
  test("Js int", () => {
    let value = %raw(`42`)
    expect(Colander.int(value)) |> toBe(true)
  })

  test("Js string", () => {
    let value = %raw(`"42"`)
    expect(Colander.int(value)) |> toBe(false)
  })

  test("Js null", () => {
    let value = %raw(`null`)
    expect(Colander.string(value)) |> toBe(false)
  })

  test("Js undefined", () => {
    let value = %raw(`undefined`)
    expect(Colander.string(value)) |> toBe(false)
  })

  test("Js object", () => {
    let value = %raw(`{"one": 1}`)
    expect(Colander.string(value)) |> toBe(false)
  })
})

describe("Test null or undefined validation", () => {
  test("Js int", () => {
    let value = %raw(`42`)
    expect(Colander.nullOrUndefined(value)) |> toBe(false)
  })

  test("Js string", () => {
    let value = %raw(`"42"`)
    expect(Colander.nullOrUndefined(value)) |> toBe(false)
  })

  test("Js null", () => {
    let value = %raw(`null`)
    expect(Colander.nullOrUndefined(value)) |> toBe(true)
  })

  test("Js undefined", () => {
    let value = %raw(`undefined`)
    expect(Colander.nullOrUndefined(value)) |> toBe(true)
  })

  test("a Js object", () => {
    let value = %raw(`{"one": 1}`)
    expect(Colander.nullOrUndefined(value)) |> toBe(false)
  })
})

describe("Test Date validation", () => {
  test("Js int", () => {
    let value = %raw(`new Date()`)
    expect(Colander.date(value)) |> toBe(true)
  })

  test("Js int", () => {
    let value = %raw(`42`)
    expect(Colander.date(value)) |> toBe(false)
  })

  test("Js string", () => {
    let value = %raw(`"42"`)
    expect(Colander.date(value)) |> toBe(false)
  })

  test("Js null", () => {
    let value = %raw(`null`)
    expect(Colander.date(value)) |> toBe(false)
  })

  test("Js undefined", () => {
    let value = %raw(`undefined`)
    expect(Colander.date(value)) |> toBe(false)
  })

  test("a Js object", () => {
    let value = %raw(`{"one": 1}`)
    expect(Colander.date(value)) |> toBe(false)
  })
})

describe("Test Field module", () => {
  open Colander

  test("Try to valid data", () => {
    let required = true
    let name = "attribute"
    let validator = Colander.string
    let value = %raw(`"a string"`)
    let data = %raw(`{"attribute": value}`)

    let result = Field.valid(~required, ~name, ~validator, data)

    expect(result) |> toEqual((name, Ok(value)))
  })

  test("Try to valid a invalid data type", () => {
    let required = true
    let name = "attribute"
    let validator = Colander.int
    let data = %raw(`{"attribute": "a string"}`)

    let result = Field.createElement(~required, ~name, ~validator, ())(data)

    expect(result) |> toEqual((name, Error(Invalid)))
  })

  test("Try to valid missing attribute in data", () => {
    let required = true
    let name = "attribute"
    let validator = Colander.string
    let data = %raw(`{}`)

    let result = Field.createElement(~required, ~name, ~validator, ())(data)

    expect(result) |> toEqual((name, Error(Missing)))
  })

  test("Try to valid a not required attribute", () => {
    let required = false
    let name = "attribute"
    let value = %raw(`null`)
    let validator = Colander.string
    let data = %raw(`{"attribute": null}`)

    let result = Field.createElement(~required, ~name, ~validator, ())(data)

    expect(result) |> toEqual((name, Ok(value)))
  })

  test("Should return None for no required missing value", () => {
    let required = false
    let name = "attribute"
    let validator = Colander.string
    let data = %raw(`{}`)
    let result = Field.createElement(~required, ~name, ~validator, ())(data)

    expect(result) |> toEqual((name, Ok(%raw(`undefined`))))
  })

  test("Try to valid a date attribute", () => {
    let required = true
    let name = "date"
    let value = %raw(`new Date("2021-07-17 13:22:00")`)
    let validator = Colander.date
    let data = %raw(`{"date": new Date("2021-07-17 13:22:00")}`)

    let result = Field.createElement(~required, ~name, ~validator, ())(data)

    expect(result) |> toEqual((name, Ok(value)))
  })
})

describe("Test instanceOfDate", () => {
  test("Try to identify a valid Date", () => {
    let value = %raw(`new Date("2021-07-17 13:22:00")`)

    expect(Colander.instanceOfDate(value)) |> toBe(true)
  })

  test("Try to identify an invalid Date", () => {
    let value = %raw(`"2021-07-17 13:22:00"`)

    expect(Colander.instanceOfDate(value)) |> toBe(false)
  })
  test("Try to identify a null Date", () => {
    let value = %raw(`null`)

    expect(Colander.instanceOfDate(value)) |> toBe(false)
  })

  test("Try to identify a undefined Date", () => {
    let value = %raw(`undefined`)

    expect(Colander.instanceOfDate(value)) |> toBe(false)
  })
})

describe("Test valid", () => {
  open Colander

  test("Try to valid data", () => {
    let value = %raw(`"value"`)
    let data = %raw(`{"attribute": "value"}`)
    let fields = <Obj> <Field name="attribute" validator=Colander.string required=true /> </Obj>

    let result = Colander.valid(data, fields)

    expect(result) |> toEqual(Ok(Js.Dict.fromArray([("attribute", value)])))
  })

  test("Try to valid data with missing field", () => {
    let data = %raw(`{}`)
    let fields = <Obj> <Field name="attribute" validator=Colander.string required=true /> </Obj>

    let result = Colander.valid(data, fields)

    expect(result) |> toEqual(Error([("attribute", Colander.Missing)]))
  })

  test("Try to valid data with invalid field", () => {
    let data = %raw(`{"attribute": 42}`)
    let fields = <Obj> <Field name="attribute" validator=Colander.string required=true /> </Obj>

    let result = Colander.valid(data, fields)

    expect(result) |> toEqual(Error([("attribute", Colander.Invalid)]))
  })
})
