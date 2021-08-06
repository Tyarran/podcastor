module Episode = {
  type t = {
    content: string,
    slug: string,
    /* url: string, */
    title: string,
    date: Js.Date.t,
    filePath: string,
  }
  type metadata = {title: string, slug: string, date: string}
}

module Podcast = {
  type t = {
    name: string,
    description: string,
    image: string,
    slug: string,
    path: string,
    episodes: list<Episode.t>,
    episodesCount: int,
  }
}

module Context = {
  type t = {
    siteName: string,
    description: string,
    logo: string,
    podcasts: array<Podcast.t>,
  }
}

module Config = {
  type podcast = {
    name: string,
    description: string,
    image: string,
    slug: string,
    path: string,
  }

  type t = {
    name: string,
    description: string,
    logo: string,
    podcasts: array<podcast>,
  }
}
