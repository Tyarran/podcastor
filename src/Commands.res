let configFile = "./config.toml"

let handleConfigError = errors => {
  let formatedError = Js.Json.stringifyWithSpace(Bindings.Console.toJson(errors), 2)
  Js.log(<Colorize color=Colorize.Red> "Configuration error: " </Colorize> ++ "\n" ++ formatedError)
  Node.Process.exit(1)
}

let handleMissingConfigFile = path => {
  Js.log(<Colorize color=Colorize.Red> {`${path} file not found`} </Colorize>)
  Node.Process.exit(1)
}

let build = _ => {
  open Bindings.Node
  switch Fs.readFileSync(configFile, "utf8") {
  | Ok(content) =>
    switch Config.getConfig(content) {
    | Ok(config) => Js.log(config)
    | Error(errors) => handleConfigError(errors)
    }
  | Error(_) => handleMissingConfigFile(configFile)
  }
}
