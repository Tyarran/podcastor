/* let args = Belt.Array.sliceToEnd(Bindings.Node.Process.argv, 2) */
let args = Bindings.Node.Process.argv

let actionCommand: Bindings.Yargs.command = {
  alias: "c",
  default: "build",
}

open Bindings.Yargs
let result =
  yargs1(Helper.hideBin(args))
  ->scriptName("podcastor")
  ->version(Constants.version)
  ->usage(
    <Colorize color=Colorize.Red> "podcastor" </Colorize> ++
    <Colorize color=Colorize.Yellow>
      " [command]"
    </Colorize> ++ "\n\nA tool to generate podcast static sites",
  )
  ->help()
  ->epilogue("Fork me on Github : https://github.com/rcommande/podcastor")
  ->command(
    "build",
    "Run static site generation",
    yargs => {
      let _ = positional(
        yargs,
        "destination",
        Js.Dict.fromArray([
          ("type", "string"),
          ("default", "./output/"),
          ("describe", "Destination"),
        ]),
      )
    },
    yargs => {
      Commands.build(yargs)
    },
  )
  ->argv
