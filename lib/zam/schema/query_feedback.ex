defmodule Zam.Schema.QueryFeedback do
  @moduledoc """
  Query Zams Feedback table
  """
  import Ecto.Query, warn: false
  alias Zam.Repo

  alias Zam.Schema.{Feedback}

  def count() do
    Feedback
    |> Repo.aggregate(:count)
  end

  def count(ip) do
    Feedback
    |> where(ip: ^ip)
    |> Repo.aggregate(:count)
  end

  def get_recent() do
    Feedback
    |> order_by([f], desc: f.inserted_at)
    |> Repo.all()
  end

  def delete(id) do
    Feedback
    |> Repo.get!(id)
    |> Repo.delete()
  end

  def create(%{} = attrs), do: %Feedback{} |> Feedback.changeset(attrs) |> Repo.insert()
end