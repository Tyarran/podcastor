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

let hasErrors = episodes => {
  let errored = Belt.Array.keep(episodes, episode => {
    switch episode {
    | Ok(_) => false
    | Error(_) => true
    }
  })
  switch Belt.Array.length(errored) != 0 {
  | true => (true, errored)
  | false => (false, [])
  }
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

Js.log(<Colorize color=Colorize.Yellow> "Loading episode files :" </Colorize>)

let result = getEpisodePaths(podcast)->Js.Promise.then_(filepaths => {
  Belt.Array.forEach(filepaths, filepath => {
    let _ = Bindings.Node.Fs.Promise.readFile(filepath, "utf-8")->Js.Promise.then_(content => {
      let result = Reader.read(content, filepath)
      let formated = switch result {
      | Ok(_) => <Colorize color=Colorize.Green> "ok" </Colorize>
      | Error(error) => Reader.formatError(error)
      }
      Js.log(formated)->Js.Promise.resolve
    }, _)
  })->Js.Promise.resolve
}, _)

/* open Test */

/* \">>="(1, 2) */
