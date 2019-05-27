# Zam

Zam Search is a demo web project showing a full service search monolith. It can run distributed or on a single server and as one set of services will: Serve a search website (similar to say duckduckgo), crawl the web using a domain list and depth settings, store the results in your database and index those results for search. Though packaged together, splitting the 3 main services out to scale separately is fairly trivial to do.

Below you will find an explanation of tech used in the package and how to run the project locally as well as deploy it, using an ubuntu instance as an example.

***Please use responsible scraping only!***


## Packages and Tech used

### Website (Phoenix, LiveView)

The website is a standard phoenix setup with Liveview used for the search, suggestion and results.


### Storage (Postgres/Ecto)

Per discussion on elixirforum some thought Riak KV or TS would be a great solution, and indeed it is.  For now a very thin client and postgres are used so that is a potential desired update. Perhaps we can upgrade the storage client here to accept the idea
of a driver.


### Search (Sphinxsearch/Khafra/Giza)

Sphinx is used to index the stored pages from the database. It is fast, indexes efficiently and doesn't crash. Khafra eases the deployment and testing process and Giza is the Elixir client for Sphinx.

[https://sphinxsearch.com/](Sphinxsearch)
[https://hex.pm/packages/khafra_search](KhafraSearch)
[https://hex.pm/packages/giza_sphinxsearch](Giza_SphinxSearch)


### Crawling (Crawlie(forked), Quantum, Simplestatex)

Crawlie was forked in order to quickly work in a few extra features. Mainly a wait interval so robots.txt could be observed. The
interval isn't quite working as expected yet but does seem to provide some delay. Can also now set a max amount of pages to visit on a crawl attempt and set a user-agent in your crawlers headers. This combined with randomizing the order links are explored can be used to incrementally crawl large sites day by day. Quantum handles the scheduling of the Crawls. Simplestatex is used to log issues encountered with urls and tabulate crawl stats.

[https://github.com/nietaki/crawlie](Crawlie)
[https://github.com/praxis-of-nines/crawlie](CrawlieFork)
[https://hex.pm/packages/quantum](Quantum)
[https://hex.pm/packages/simplestatex](Simplestatex)

## Run this locally

These steps allow you to run a search engine website locally which will also crawl the web and index the findings. Assumes
Elixir and Postgres are installed already.  This is tested on Ubuntu and some options may vary on other systems.

```
# Setup your config first. Copy example_config/ folder to config/ and alter to your environment and wishes

> git clone https://github.com/praxis-of-nines/zam-search.git

> cd zam-search

> mix deps.get

> mix ecto.migrate

> mix zam.create.domain "https://elixirforum.html"

> mix zam.create.index 1 2 daily 1

> mix zam.crawler.crawl all

> mix khafra.sphinx.download linux_64

> mix khafra.gen.sphinxconf

> mix khafra.sphinx.index all

> mix khafra.sphinx.searchd

> mix phx.server
```

## Deployment

Assumes you have an ubuntu instance to deploy to. There are many ways to deploy as this is a standard Elixir project. These steps
provide guidance in getting an index up and running using one possible way.

```
# Build production release
> npm run deploy --prefix assets && MIX_ENV=prod mix do phx.digest, release --env=prod

# FTP _build/prod/rel/zam/releases/0.1.0/zam.tar.gz to your production location
# SSH onto your production location

# Now init the database and create at least one domain and index (use a different domain please and don't flood our friends!)

prod#> tar xvf zam.tar.gz
prod#> bin/zam migrate
prod#> bin/zam create_domain "https://elixirforum.html"
# NOTE: use the webdomain_id from the domain you just created as first arg below
prod#> bin/zam create_index 1 3 daily 1
prod#> bin/zam crawl all

# That may take a while depending on your settings. Now let's create the index!

prod#> bin/zam download_sphinx linux_64
prod#> bin/zam gen_config
# NOTE: if you get an error you may need to do an additional linux package install:
(optional)prod#> sudo apt-get install libpq-dev
prod#> bin/zam index all
prod#> bin/zam searchd

# Ok start the website and you should be up and running
prod#> bin/zam start

# Your schedulers will take care of indexing and crawling from here on out long as the site is up
```

## Wishlist

* [Crawl] Utilize XML sitemaps
* [Index] Add to suggestions whole phrase (1st search result)
* [Web/Search] Add some search key characters for special purpose (|| for or and quoted words etc)
* [Web] Pagination (load more results or whatever)
* [Crawl Bug] Crawl intervals have to be implemented better
* [Crawl] Need more parser options (parse different areas of html situationally)
* [Index] Implement Zam Score and Link Score (Zam score is general search wellness and quality of page/info, Link is how well it does in search results page ie was it relevant)
* [Index/DB] Implement more strongly in direction of an append log so historic searches can be done and index picks up only the latest entry. Makes for an easier transition to RIAK as well
* [Crawl] Make subsequent crawls start where they left off the last time
* [Web] Optimize behavior of TAB on input (fill input box with suggestion and disable default behavior)
* [Crawl] Make domain constraint optional