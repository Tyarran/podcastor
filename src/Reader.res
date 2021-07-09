type groups = {
  metadata: option<string>,
  content: string,
}

type validationErrors = array<(Js.Dict.key, Validators.reason)>

type metadataReadError = MetadataValidationError(validationErrors) | UnreadableMetadataError
type contentReadError = UnreadableContentError

type readerError =
  | FileReadError(string)
  | ContentReadError(string)
  | ValidationError(string, validationErrors)
  | MetadataReadError(string)
  | MissingMetadata(string)

@get external getGroups: 'a => groups = "groups"

let loadMetadata = yamlContent => {
  try {
    open Validators
    let readed = Bindings.JsYaml.loadMetadata(yamlContent)
    let validated = valid(
      readed,
      <Obj>
        <Field name="Title" required=true validator=string />
        <Field name="date" required=true validator=string />
        <Field name="Slug" required=false validator=string />
      </Obj>,
    )
    switch validated {
    | Ok(value) => {
        let rawMetadata = Bindings.JsYaml.toMetadata(value)
        let metadata: Types.Episode.metadata = {
          title: rawMetadata.title,
          date: rawMetadata.date,
          slug: Utils.defaultString(rawMetadata.slug, Bindings.Slugger.slug(rawMetadata.title)),
        }
        Ok(metadata)
      }
    | Error(errors) => Error(MetadataValidationError(errors))
    }
  } catch {
  | Js.Exn.Error(_) => Error(UnreadableMetadataError)
  }
}

let loadContent = markdownContent => {
  try {
    Ok(Bindings.Marked.marked(markdownContent))
  } catch {
  | Js.Exn.Error(_) => Error()
  }
}

let splitMetadataAndContent = content => {
  let regex = Js.Re.fromStringWithFlags(
    "^(?:(?<metadata>((.*:.*)\n)+)\n)?(?<content>.*)$",
    ~flags="gm",
  )
  let result = Js.Re.exec_(regex, content)
  switch result {
  | Some(r) => {
      let groups = getGroups(Js.Re.captures(r))
      Some((groups.metadata, groups.content))
    }

  | None => None
  }
}

let makeEpisode = (metadata: Types.Episode.metadata, content, path) => {
  let episode: Types.Episode.t = {
    content: content,
    slug: metadata.slug,
    title: metadata.title,
    date: Js.Date.fromString(metadata.date),
    filePath: path,
  }
  episode
}

let formatError = error => {
  open Validators

  let format = (path, message) =>
    <Colorize color=Colorize.White>
      {path ++ "\n"} <Colorize color=Colorize.Red> message </Colorize>
    </Colorize>

  switch error {
  | ContentReadError(path) => format(path, "Content parsing error")
  | MetadataReadError(path) => format(path, "Content parsing error")
  | ValidationError(path, errors) =>
    let message = Belt.Array.reduce(errors, "", (acc, error) => {
      let (name, error) = error
      let formatedError = switch error {
      | Missing => `Missing field "${name}"`
      | Required => `Value required "${name}"`
      | Invalid => `"${name}" Invalid format`
      }
      switch acc {
      | "" => formatedError
      | _ => acc ++ "\n" ++ formatedError
      }
    })
    format(path, message)
  | FileReadError(path) => format(path, "file read error")
  | MissingMetadata(path) => format(path, "Missing metadata")
  }
}

let read = (fileContent, filepath) => {
  switch splitMetadataAndContent(fileContent) {
  | Some(Some(metadataPart), contentPart) =>
    switch loadMetadata(metadataPart) {
    | Ok(metadata) =>
      switch loadContent(contentPart) {
      | Ok(content) => Ok(makeEpisode(metadata, content, filepath))
      | Error(_) => Error(ContentReadError(filepath))
      }
    | Error(UnreadableMetadataError) => Error(MetadataReadError(filepath))
    | Error(MetadataValidationError(errors)) => Error(ValidationError(filepath, errors))
    }
  | Some(None, _) => Error(MissingMetadata(filepath))
  | None => Error(FileReadError(filepath))
  }
}
