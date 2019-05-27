use Mix.Config

config :khafra_search, :source_weblink,
  parent: :source_sqldb,
  query: """
    SELECT wl.id, wl.title, wl.link, wl.description, wl.samples, wl.score_link, wl.score_zam, \\
      extract(epoch FROM wl.updated_at) AS updated_timestamp, tb.text \\
    FROM weblinks wl \\
      LEFT JOIN text_blobs tb ON wl.id = tb.weblink_id
  """,
  attributes: [
    link:              :string,
    score_link:        :integer,
    score_zam:         :integer,
    updated_timestamp: :datetime],
  fields: [
    title:       :string,
    description: :string,
    samples:     :string,
    text:        :string]
