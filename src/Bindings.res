module Node = {
  module Fs = {
    module Promise = {
      @module("fs/promises") external readdir: string => Js.Promise.t<array<string>> = "readdir"

      @module("fs/promises")
      external writeFile: (string, 'a) => Js.Promise.t<Js.undefined<string>> = "writeFile"

      @module("fs/promises")
      external readFile: (string, string) => Js.Promise.t<string> = "readFile"
    }
  }
  @val external dirname: string = "__dirname"
  module Process = {
    @module("process") @val external cwd: unit => string = "cwd"
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
    date: string,
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
