let podcast: Types.Podcast.t = {
  name: "Mon premier podcast",
  description: "Le meilleur podcast",
  image: "https://via.placeholder.com/150",
  slug: Bindings.Slugger.slug("mon premier podcast"),
  // path: Bindings.Node.Process.cwd() ++ "/podcasts/second",
  episodes: list{},
  episodesCount: 0,
  path: Bindings.Node.Process.cwd() ++ "/podcasts/first",
}

let context: Types.Context.t = {
  siteName: "Podcastor",
  description: "The static podcast website generator",
  logo: "https://image.freepik.com/vecteurs-libre/logo-mignon-castor_80802-224.jpg",
  podcasts: [podcast],
}

let splitExt = filename => {
  let splitted = Js.String.split(".", filename)
  "." ++ splitted[Belt.Array.length(splitted) - 1]
}

let getEpisodePaths = (podcast: Types.Podcast.t) => {
  Bindings.Node.Fs.Promise.readdir(podcast.path)->Js.Promise.then_(filenames => {
    Belt.Array.keep(filenames, filename => splitExt(filename) == ".md")
    ->Belt.Array.map(filename => podcast.path ++ "/" ++ filename)
    ->Js.Promise.resolve
  }, _)
}

let sortEpisodesByDate = (a: Types.Episode.t, b: Types.Episode.t) => {
  switch a.date < b.date {
  | true => 1
  | false =>
    switch a.date > b.date {
    | true => -1
    | false => 0
    }
  }
}

let getEpisodes = episodefilePaths => {
  let promises = Belt.Array.map(episodefilePaths, filepath =>
    Bindings.Node.Fs.Promise.readFile(filepath, "utf-8")
  )

  Js.Promise.all(promises)->Js.Promise.then_(fileContents => {
    let readed = Belt.Array.mapWithIndex(fileContents, (index, fileContent) => {
      Reader.read(fileContent, episodefilePaths[index])
    })

    let (episodes, errors) = Belt.Array.reduce(readed, (list{}, list{}), (acc, item) => {
      let (episodes, errors) = acc
      switch item {
      | Ok(episode) => (list{episode, ...episodes}, errors)
      | Error(error) => (episodes, list{error, ...errors})
      }
    })
    switch Belt.List.length(errors) > 0 {
    | true => {
        Js.log(<Colorize color=Colorize.Red> "Parsing errors :" </Colorize>)
        Belt.List.forEach(errors, error => {
          Js.log(Reader.formatError(error))
        })
      }

    | false => {
        let result = episodes->Belt.List.sort(sortEpisodesByDate)

        let context: Types.Context.t = {
          siteName: "Podcastor",
          description: "The static podcast website generator",
          logo: "https://image.freepik.com/vecteurs-libre/logo-mignon-castor_80802-224.jpg",
          podcasts: [
            {
              name: "Mon premier podcast",
              description: "Le meilleur podcast",
              image: "https://via.placeholder.com/150",
              slug: Bindings.Slugger.slug("mon premier podcast"),
              path: Bindings.Node.Process.cwd() ++ "/podcasts/second",
              episodes: result,
              episodesCount: Belt.List.length(result),
            },
          ],
        }
        Js.log(context)
      }
    }->Js.Promise.resolve
  }, _)
}

/* Js.log(<Colorize color=Colorize.Yellow> "Loading episode files :" </Colorize>) */

/* type arguments = {destination: string} */
/* external toArgument: Bindings.Yargs.t => arguments = "%identity" */

/* let result = getEpisodePaths(podcast)->Js.Promise.then_(filepaths => { */
/* Belt.Array.forEach(filepaths, filepath => { */
/* let _ = Bindings.Node.Fs.Promise.readFile(filepath, "utf-8")->Js.Promise.then_(content => { */
/* let result = Reader.read(content, filepath) */
/* switch result { */
/* | Ok(episode) => Js.log(episode) */
/* | Error(error) => Js.log(Reader.formatError(error)) */
/* }->Js.Promise.resolve */
/* }, _) */
/* })->Js.Promise.resolve */
/* }, _) */
/* Js.log(result) */

/* let config = Config.findCOnfigToml() */
/* %debugger */

/* let build = _ => { */
/* let config = Config.findConfigToml() */
/* let _ = switch config { */
/* | Ok(config) => Js.log(config) */
/* | Error(errors) => Js.log(errors[0].instancePath) */
/* /1* | Error(errors) => Js.log(errors[0].propertyName) *1/ */
/* } */
/* /1* switch config { *1/ */
/* /1* | Ok(config) => Js.log(config) *1/ */
/* /1* | Error(errors) => Js.log(errors) *1/ */
/* /1* } *1/ */
/* } */

/* let _ = ContextBuilder.getPodcastsPaths("/home/romain/Projects/podcastor/podcasts/") */
