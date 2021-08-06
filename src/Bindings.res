module Node = {
  module Fs = {
    type stat

    module Promise = {
      @module("fs/promises") external readdir: string => Js.Promise.t<array<string>> = "readdir"

      @module("fs/promises")
      external writeFile: (string, 'a) => Js.Promise.t<Js.undefined<string>> = "writeFile"

      @module("fs/promises")
      external readFile: (string, string) => Js.Promise.t<string> = "readFile"

      @module("fs/promises")
      external stat: string => Js.Promise.t<stat> = "stat"
    }

    module Stats = {
      @send
      external isDirectory: stat => bool = "isDirectory"
    }
    @module("fs")
    external readFileSync_: (string, string) => string = "readFileSync"

    let readFileSync = (path, encoding) => {
      try {
        Ok(readFileSync_(path, encoding))
      } catch {
      | Js.Exn.Error(obj) =>
        switch Js.Exn.message(obj) {
        | Some(m) => Error(m)
        | None => Error("Unkown Error")
        }
      }
    }
  }

  @val external dirname: string = "__dirname"
  module Process = {
    @module("process") @val external cwd: unit => string = "cwd"
    @module("process") @val external argv: array<string> = "argv"
  }
}

module Nunjucks = {
  @module("nunjucks") external render: (string, Types.Context.t) => string = "render"
  @module("nunjucks") external configure: (string, Types.Context.t) => string = "configure"
}

module Marked = {
  type rec token = {
    \"type": string,
    raw: string,
    depth: int,
    text: string,
    tokens: array<token>,
  }
  @module external marked: string => string = "marked"
  @module("marked") external lexer: string => array<token> = "lexer"
  @module("marked") external use: 'a => unit = "use"
}

module MetaMarked = {
  @module external metaMarked: string => string = "meta-marked"
}

module Multimarkdown = {
  @module("mmd") external convert: string => string = "convert"
}

module Slugger = {
  @module external slug: string => string = "slugger"
}

module JsYaml = {
  type metadata = {
    @as("Title") title: string,
    @as("Date") date: string,
    @as("Slug") slug: option<string>,
  }
  external toMetadata: Js.Dict.t<Colander.raw> => metadata = "%identity"

  @module("js-yaml") external loadMetadata: string => Js.Dict.t<Colander.raw> = "load"
}

module Chalk = {
  @module("chalk") external red: string => string = "red"
  @module("chalk") external white: string => string = "white"
  @module("chalk") external yellow: string => string = "yellow"
  @module("chalk") external green: string => string = "green"
  @get external bold: string => string = "bold"
}

module Yargs = {
  type t
  type command = {
    alias: string,
    default: string,
  }
  @module external yargs: unit => t = "yargs"
  @module external yargs1: 'a => t = "yargs"
  @send external scriptName: (t, string) => t = "scriptName"
  @send external usage: (t, string) => t = "usage"
  @send external help: (t, unit) => t = "help"
  @send external describe: (t, string) => t = "describe"
  @send external epilogue: (t, string) => t = "epilogue"
  @send external command: (t, string, string, t => unit, t => unit) => t = "command"
  @send external defaultCommand: (t, array<string>, string, t => unit, t => unit) => t = "command"
  @send external positionalCommand: (t, string, string, t => t) => t = "command"
  @send external version: (t, string) => t = "version"
  @send external positional: (t, string, Js.Dict.t<string>) => t = "positional"
  @send external parse: (t, array<string>) => t = "parse"

  @get external argv: t => t = "argv"
  module Helper = {
    @module("yargs/helpers") external hideBin: array<string> => array<string> = "hideBin"
  }
}

module Toml = {
  type t
  @module("toml") external parse_: string => t = "parse"

  let parse = content => {
    try {
      Ok(parse_(content))
    } catch {
    | Js.Exn.Error(obj) =>
      switch Js.Exn.message(obj) {
      | Some(m) => Error("Caught a JS exception! Message: " ++ m)
      | None => Error("Unknown error")
      }
    }
  }
}

module Ajv = {
  type t
  type f<'a> = 'a => bool

  type errorType = {additionalProperty: string}
  type error = {
    instancePath: string,
    schemaPath: string,
    keyword: string,
    params: errorType,
    message: string,
    @return(nullable) propertyName: string,
  }

  type errors = array<error>
  @get external errors_: f<'a> => errors = "errors"
  @send external compile_: (t, 'a) => f<'b> = "compile"
  @module @new external make: unit => t = "ajv"
  @module @new external makeWithOptions: 'a => t = "ajv"
  exception CompilationError(Js.Exn.t)

  let compile = (ajv, schema) => {
    try {
      let validator = compile_(ajv, schema)
      data =>
        switch validator(data) {
        | true => Ok(data)
        | false => Error(validator->errors_)
        }
    } catch {
    | Js.Exn.Error(error) => raise(CompilationError(error))
    }
  }
}

module Console = {
  external toJson: 'a => Js.Json.t = "%identity"

  let log = value => {
    let json = toJson(value)
    json->Js.Json.stringifyWithSpace(2)->Js.log
  }
}
