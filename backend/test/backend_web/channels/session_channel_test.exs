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
    test "responds with feedback", %{socket: socket} do
      ref = push(socket, "finished_speaking", %{})
      assert_reply(ref, :ok, payload)
      assert is_binary(payload["feedback"])
      assert String.length(payload["feedback"]) > 0
    end

    test "feedback is one of predefined messages", %{socket: socket} do
      valid_messages = [
        "Nice pacing. Keep it gentle.",
        "Try a soft start next time.",
        "Good breath before speaking.",
        "You're doing great. Take your time.",
        "Smooth delivery. Well done.",
        "Remember to breathe between phrases.",
        "Great effort! You're making progress."
      ]

      ref = push(socket, "finished_speaking", %{})
      assert_reply(ref, :ok, payload)
      assert Enum.member?(valid_messages, payload["feedback"])
    end
  end

  describe "restart_session" do
    test "acknowledges restart", %{socket: socket} do
      ref = push(socket, "restart_session", %{})
      assert_reply(ref, :ok)
    end
  end
end
