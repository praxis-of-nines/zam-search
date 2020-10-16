defmodule Zam.Crawler.Model.PageData do
  defstruct index: nil, updated_at: nil, uri: %{}, title: "", img: nil, imgs: [], code: 200, headings: %{:h1 => [], :h2 => []}, text: "", samples: ""
end