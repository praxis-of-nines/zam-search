defmodule Zam.Crawler.Model.PageData do
  defstruct uri: %{}, title: "", code: 200, headings: %{:h1 => [], :h2 => []}, text: "", samples: ""
end