open Bindings

type rawPodcast = {
  name: string,
  description: string,
  image: string,
  slug: string,
  path: string,
}

type rawConfig = {
  name: string,
  description: string,
  logo: string,
  podcasts: array<rawPodcast>,
}

let schema = {
  "type": "object",
  "properties": {
    "name": {"type": "string"},
    "description": {"type": "string"},
    "logo": {"type": "string"},
    "podcasts": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "name": {"type": "string"},
          "description": {"type": "string"},
          "image": {"type": "string"},
          "slug": {"type": "string"},
          "path": {"type": "string"},
        },
        "required": ["name", "description", "image", "slug", "path"],
        "additionalProperties": false,
      },
    },
  },
  "required": ["name", "description", "logo"],
  "additionalProperties": false,
}

external load: 'a => rawConfig = "%identity"

let make = raw => {
  let config: Types.Config.t = {
    name: raw.name,
    description: raw.description,
    logo: raw.logo,
    podcasts: Belt.Array.map(raw.podcasts, raw => {
      let podcast: Types.Config.podcast = {
        name: raw.name,
        description: raw.description,
        image: raw.image,
        slug: raw.slug,
        path: raw.path,
      }
      podcast
    }),
  }
  config
}

let bind = (validator_result, callback) => {
  switch validator_result {
  | Ok(value) => Ok(callback(value->load))
  | Error(errors) => Error(errors)
  }
}

let ajv = Ajv.make()
let validator = ajv->Ajv.compile(schema)

let getConfig = content => {
  switch Toml.parse(content) {
  | Ok(parsed) =>
    switch validator(parsed) {
    | Ok(validated) => Ok(validated)
    | Error(errors) => Error(errors)
    }
  | _ => Error([])
  }
}
