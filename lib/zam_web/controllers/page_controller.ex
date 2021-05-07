defmodule ZamWeb.PageController do
  use ZamWeb, :controller

  alias Zam.Schema.Feedback
  alias Zam.Schema.QueryFeedback

  @max_feedback 5
  @feedback_sent """
    Feedback has been sent. Thank you!
  """
  @unspecific_error """
    An error occured. Did you fill one of the main 3 topics and format your urls correctly?
  """
  @exceeded_max_feedback """
    You have sent enough feedback for now. 
    Once your entries have been addressed you can add more.
  """

  def index(conn, _params) do
    conn    
    |> render("index.html")
  end

  def about(conn, _params) do
    conn
    |> render("about.html")
  end

  def feedback(%{remote_ip: {ip1, ip2, ip3, ip4}} = conn, %{"feedback" => feedback}) do
    ip = "#{ip1}.#{ip2}.#{ip3}.#{ip4}"

    cond do 
      QueryFeedback.count(ip) < @max_feedback ->
        case QueryFeedback.create(feedback) do
          {:ok, _feedback} ->
            conn
            |> put_flash(:info, @feedback_sent)
            |> render("feedback.html", changeset: default_feedback_changeset(ip))
          {:error, %Ecto.Changeset{} = changeset} ->
            IO.inspect changeset
            conn
            |> put_flash(:error, @unspecific_error)
            |> render("feedback.html", changeset: changeset)
        end
      true ->
        conn
        |> put_flash(:info, @exceeded_max_feedback)
        |> render("feedback.html", changeset: default_feedback_changeset(ip))
    end
  end

  def feedback(%{remote_ip: ip} = conn, _) do
    render(conn, "feedback.html", changeset: default_feedback_changeset(ip))
  end

  defp default_feedback_changeset({ip1, ip2, ip3, ip4}), do: %Feedback{} 
  |> Feedback.changeset(%{ip: "#{ip1}.#{ip2}.#{ip3}.#{ip4}"})

  defp default_feedback_changeset(_), do: %Feedback{} |> Feedback.changeset(%{ip: nil})
end
