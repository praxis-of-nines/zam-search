defmodule Zam.Crawler.Model.PageData do
  defstruct index: nil, uri: %{}, title: "", img: "", code: 200, headings: %{:h1 => [], :h2 => []}, text: "", samples: ""
end