open Jest
open Expect

describe("Test string validation", () => {
  test("javascript string", () => {
    let value = %raw(`"a string"`)
    expect(Colander.string(value)) |> toBe(true)
  })

  test("javascript null", () => {
    let value = %raw(`null`)
    expect(Colander.string(value)) |> toBe(false)
  })

  test("javascript undefined", () => {
    let value = %raw(`undefined`)
    expect(Colander.string(value)) |> toBe(false)
  })

  test("javascript int", () => {
    let value = %raw(`42`)
    expect(Colander.string(value)) |> toBe(false)
  })

  test("javascript object", () => {
    let value = %raw(`{"one": 1}`)
    expect(Colander.string(value)) |> toBe(false)
  })
})

describe("Test int validation", () => {
  test("javascript int", () => {
    let value = %raw(`42`)
    expect(Colander.int(value)) |> toBe(true)
  })

  test("javascript string", () => {
    let value = %raw(`"42"`)
    expect(Colander.int(value)) |> toBe(false)
  })

  test("javascript null", () => {
    let value = %raw(`null`)
    expect(Colander.string(value)) |> toBe(false)
  })

  test("javascript undefined", () => {
    let value = %raw(`undefined`)
    expect(Colander.string(value)) |> toBe(false)
  })

  test("javascript object", () => {
    let value = %raw(`{"one": 1}`)
    expect(Colander.string(value)) |> toBe(false)
  })
})

describe("Test null or undefined validation", () => {
  test("javascript int", () => {
    let value = %raw(`42`)
    expect(Colander.nullOrUndefined(value)) |> toBe(false)
  })

  test("javascript string", () => {
    let value = %raw(`"42"`)
    expect(Colander.nullOrUndefined(value)) |> toBe(false)
  })

  test("javascript null", () => {
    let value = %raw(`null`)
    expect(Colander.nullOrUndefined(value)) |> toBe(true)
  })

  test("javascript undefined", () => {
    let value = %raw(`undefined`)
    expect(Colander.nullOrUndefined(value)) |> toBe(true)
  })

  test("a javascript object", () => {
    let value = %raw(`{"one": 1}`)
    expect(Colander.nullOrUndefined(value)) |> toBe(false)
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
