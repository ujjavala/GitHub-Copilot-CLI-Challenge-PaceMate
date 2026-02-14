defmodule BackendWeb.SessionChannelTest do
  use BackendWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      BackendWeb.UserSocket
      |> socket("user_id", %{})
      |> subscribe_and_join(BackendWeb.SessionChannel, "session:user_session")

    %{socket: socket}
  end

  describe "join" do
    test "joins the channel successfully", %{socket: socket} do
      assert socket.channel == BackendWeb.SessionChannel
      assert socket.topic == "session:user_session"
    end
  end

  describe "finished_speaking" do
    test "responds with feedback structure", %{socket: socket} do
      ref = push(socket, "finished_speaking", %{"speech" => "Hello world, this is a test speech"})
      assert_reply(ref, :ok, payload, 5000)
      assert is_binary(payload["encouragement"])
      assert is_binary(payload["pacing"])
      assert is_binary(payload["tips"])
      assert String.length(payload["encouragement"]) > 0
    end

    test "handles empty payload with fallback feedback", %{socket: socket} do
      ref = push(socket, "finished_speaking", %{})
      assert_reply(ref, :ok, payload)
      assert is_binary(payload["encouragement"])
      assert is_binary(payload["pacing"])
      assert is_binary(payload["tips"])
      assert payload["pacing"] == "Keep practicing your pacing!"
    end
  end

  describe "restart_session" do
    test "acknowledges restart", %{socket: socket} do
      ref = push(socket, "restart_session", %{})
      assert_reply(ref, :ok)
    end
  end
end
