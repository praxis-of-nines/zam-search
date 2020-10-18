defmodule Zam.Guards do
  @moduledoc """
  Custom guard classes generic to Zam
  """
  defguard is_date?(value) when value in ["info", "warning", "error"]
end