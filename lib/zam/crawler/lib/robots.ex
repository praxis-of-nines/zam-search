defmodule Zam.Crawler.Robots do
  @moduledoc """
  Retrieve a domains robots.txt file and return a keywork list of extracted options for the
  url filter to obey.
  """

  @doc """
  Attempt a robots.txt retrieval using the passed url and line by line, add options Zam can
  understand

  ## Example

    iex> Zam.Crawler.ParseRobots.parse("https://www.infogalactic.com/robots.txt")
    {:ok, [{:}]}
  """
  def parse_from(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {_, instructions} = Enum.reduce(String.split(body, "\n"), {:ok, []}, fn line, {directive, acc} ->
          case parse_line(String.downcase(String.trim(String.replace(line, " ", ""))), directive) do
            {:ok, instruction, new_directive} ->
              {new_directive, [instruction|acc]}
            {:skip, new_directive} ->
              {new_directive, acc}
          end
        end)

        {:ok, instructions}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "no robots file"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  # Use default directive (meaning end current agent parse for example)
  defp parse_line("", _), do: {:skip, :ok}

  # User agent to obey: take next instruction
  defp parse_line("user-agent:*", _), do: {:skip, :use}
  defp parse_line("user-agent:zambot", _), do: {:skip, :use}
  defp parse_line("user-agent:" <> _, _), do: {:skip, :ignore}

  defp parse_line("disallow:" <> pattern, :use), do: {:ok, {:disallow, pattern}, :use}
  defp parse_line("crawl-delay:" <> delay, :use) do
    case Integer.parse(delay) do
      {parsed_int, _} -> {:ok, {:delay_seconds, parsed_int}, :use}
      :error -> {:skip, :use}
    end
  end

  defp parse_line(_, directive), do: {:skip, directive}
end