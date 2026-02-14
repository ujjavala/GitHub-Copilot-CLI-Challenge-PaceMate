defmodule BackendWeb.UserSocket do
  use Phoenix.Socket

  channel "session:*", BackendWeb.SessionChannel

  @impl true
  def connect(_params, socket) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
