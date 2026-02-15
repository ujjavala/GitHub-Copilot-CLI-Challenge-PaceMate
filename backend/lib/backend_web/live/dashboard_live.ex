defmodule BackendWeb.DashboardLive do
  use BackendWeb, :live_view
  alias Backend.Sessions
  alias Backend.Constants

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to real-time updates
      Phoenix.PubSub.subscribe(Backend.PubSub, "dashboard:updates")

      # Schedule periodic updates every 5 seconds
      :timer.send_interval(5000, self(), :update_data)
    end

    socket =
      socket
      |> assign(:loading, false)
      |> assign(:show_milestone, false)
      |> assign(:milestone_message, "")
      |> load_dashboard_data()

    {:ok, socket}
  end

  @impl true
  def handle_info({:new_session, _feedback}, socket) do
    # Real-time update when new session is created
    socket =
      socket
      |> load_dashboard_data()
      |> check_and_show_milestone()

    {:noreply, socket}
  end

  @impl true
  def handle_info(:update_data, socket) do
    {:noreply, load_dashboard_data(socket)}
  end

  @impl true
  def handle_info(:hide_milestone, socket) do
    {:noreply, assign(socket, show_milestone: false)}
  end

  defp load_dashboard_data(socket) do
    socket
    |> assign(:total_sessions, Sessions.count_sessions())
    |> assign(:total_words, Sessions.total_words())
    |> assign(:average_wpm, Sessions.average_wpm())
    |> assign(:practice_streak, Sessions.practice_streak())
    |> assign(:recent_sessions, Sessions.list_recent_sessions(30))
    |> assign(:wpm_data, Sessions.wpm_over_time(30))
    |> assign(:frequency_data, Sessions.practice_frequency(90))
  end

  defp check_and_show_milestone(socket) do
    total = socket.assigns.total_sessions
    streak = socket.assigns.practice_streak

    milestone =
      cond do
        total == 1 -> Constants.milestone_first_session()
        total == 10 -> Constants.milestone_10_sessions()
        total == 50 -> Constants.milestone_50_sessions()
        total == 100 -> Constants.milestone_100_sessions()
        streak == 7 -> Constants.milestone_7_day_streak()
        streak == 30 -> Constants.milestone_30_day_streak()
        true -> nil
      end

    if milestone do
      # Show milestone for 5 seconds
      Process.send_after(self(), :hide_milestone, 5000)

      socket
      |> assign(:show_milestone, true)
      |> assign(:milestone_message, milestone)
    else
      socket
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="dashboard-container">
      <%= if @show_milestone do %>
        <div class="milestone-toast">
          <%= @milestone_message %>
        </div>
      <% end %>

      <header class="dashboard-header">
        <h1 class="dashboard-title"><%= Constants.dashboard_title() %></h1>
        <p class="dashboard-subtitle"><%= Constants.dashboard_subtitle() %></p>
      </header>

      <div class="stats-grid">
        <.stat_card
          icon="🎯"
          value={@total_sessions}
          label={Constants.stat_total_sessions()}
          color="blue"
        />
        <.stat_card
          icon="💬"
          value={format_number(@total_words)}
          label={Constants.stat_total_words()}
          color="cyan"
        />
        <.stat_card
          icon="⚡"
          value={"#{@average_wpm}"}
          label={Constants.stat_average_wpm()}
          color="green"
        />
        <.stat_card
          icon="🔥"
          value={@practice_streak}
          label={Constants.stat_practice_streak()}
          color="orange"
        />
      </div>

      <%= if @total_sessions > 0 do %>
        <div class="charts-container">
          <div class="chart-card">
            <h2 class="chart-title"><%= Constants.chart_wpm_title() %></h2>
            <.wpm_chart data={@wpm_data} />
          </div>

          <div class="chart-card">
            <h2 class="chart-title"><%= Constants.chart_frequency_title() %></h2>
            <.frequency_chart data={@frequency_data} />
          </div>
        </div>

        <div class="sessions-list">
          <h2 class="section-title"><%= Constants.chart_recent_sessions_title() %></h2>
          <div class="sessions-grid">
            <%= for session <- Enum.take(@recent_sessions, 10) do %>
              <.session_card session={session} />
            <% end %>
          </div>
        </div>
      <% else %>
        <div class="empty-state">
          <div class="empty-icon">🎤</div>
          <p class="empty-message"><%= Constants.no_sessions_message() %></p>
          <a href="http://localhost:3000" class="start-button">Start Your First Session</a>
        </div>
      <% end %>
    </div>

    <style>
      .dashboard-container {
        min-height: 100vh;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 2rem;
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
      }

      .milestone-toast {
        position: fixed;
        top: 2rem;
        right: 2rem;
        background: white;
        color: #667eea;
        padding: 1rem 2rem;
        border-radius: 12px;
        box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        font-size: 1.25rem;
        font-weight: 600;
        animation: slideInRight 0.4s ease-out, pulse 0.6s ease-in-out 0.4s;
        z-index: 1000;
      }

      .dashboard-header {
        text-align: center;
        margin-bottom: 3rem;
        animation: fadeInDown 0.6s ease-out;
      }

      .dashboard-title {
        font-size: 3rem;
        font-weight: 800;
        color: white;
        margin: 0;
        text-shadow: 0 4px 12px rgba(0,0,0,0.1);
      }

      .dashboard-subtitle {
        font-size: 1.25rem;
        color: rgba(255,255,255,0.9);
        margin: 0.5rem 0 0 0;
      }

      .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        gap: 1.5rem;
        margin-bottom: 3rem;
      }

      .stat-card {
        background: white;
        border-radius: 16px;
        padding: 2rem;
        text-align: center;
        box-shadow: 0 8px 32px rgba(0,0,0,0.1);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        animation: fadeInUp 0.6s ease-out backwards;
      }

      .stat-card:hover {
        transform: translateY(-8px);
        box-shadow: 0 12px 48px rgba(0,0,0,0.15);
      }

      .stat-card:nth-child(1) { animation-delay: 0.1s; }
      .stat-card:nth-child(2) { animation-delay: 0.2s; }
      .stat-card:nth-child(3) { animation-delay: 0.3s; }
      .stat-card:nth-child(4) { animation-delay: 0.4s; }

      .stat-icon {
        font-size: 3rem;
        margin-bottom: 0.5rem;
        animation: bounce 2s ease-in-out infinite;
      }

      .stat-value {
        font-size: 2.5rem;
        font-weight: 700;
        margin: 0.5rem 0;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
      }

      .stat-label {
        font-size: 0.875rem;
        color: #6b7280;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        font-weight: 600;
      }

      .charts-container {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
        gap: 2rem;
        margin-bottom: 3rem;
      }

      .chart-card {
        background: white;
        border-radius: 20px;
        padding: 2rem;
        box-shadow: 0 8px 32px rgba(0,0,0,0.1);
        animation: fadeInUp 0.6s ease-out 0.5s backwards;
      }

      .chart-title {
        font-size: 1.5rem;
        font-weight: 700;
        color: #1f2937;
        margin: 0 0 1.5rem 0;
      }

      .sessions-list {
        animation: fadeInUp 0.6s ease-out 0.7s backwards;
      }

      .section-title {
        font-size: 2rem;
        font-weight: 700;
        color: white;
        margin: 0 0 1.5rem 0;
        text-shadow: 0 2px 8px rgba(0,0,0,0.1);
      }

      .sessions-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
        gap: 1.5rem;
      }

      .session-card {
        background: white;
        border-radius: 12px;
        padding: 1.5rem;
        box-shadow: 0 4px 16px rgba(0,0,0,0.1);
        transition: transform 0.2s ease;
        animation: fadeInUp 0.4s ease-out backwards;
      }

      .session-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 8px 24px rgba(0,0,0,0.15);
      }

      .session-date {
        font-size: 0.875rem;
        color: #6b7280;
        font-weight: 600;
        margin-bottom: 0.5rem;
      }

      .session-metrics {
        display: flex;
        gap: 1rem;
        margin: 0.75rem 0;
      }

      .session-metric {
        display: flex;
        align-items: center;
        gap: 0.25rem;
        font-size: 0.875rem;
        color: #374151;
      }

      .session-speech {
        font-size: 0.875rem;
        color: #4b5563;
        line-height: 1.5;
        margin-top: 0.75rem;
        overflow: hidden;
        text-overflow: ellipsis;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
      }

      .empty-state {
        text-align: center;
        padding: 4rem 2rem;
        background: white;
        border-radius: 20px;
        box-shadow: 0 8px 32px rgba(0,0,0,0.1);
        animation: fadeInUp 0.6s ease-out;
      }

      .empty-icon {
        font-size: 5rem;
        margin-bottom: 1rem;
        animation: bounce 2s ease-in-out infinite;
      }

      .empty-message {
        font-size: 1.25rem;
        color: #6b7280;
        margin-bottom: 2rem;
      }

      .start-button {
        display: inline-block;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 1rem 2.5rem;
        border-radius: 12px;
        font-weight: 600;
        text-decoration: none;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
        box-shadow: 0 4px 16px rgba(102, 126, 234, 0.4);
      }

      .start-button:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 24px rgba(102, 126, 234, 0.6);
      }

      @keyframes fadeInUp {
        from {
          opacity: 0;
          transform: translateY(30px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }

      @keyframes fadeInDown {
        from {
          opacity: 0;
          transform: translateY(-30px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }

      @keyframes slideInRight {
        from {
          transform: translateX(100%);
          opacity: 0;
        }
        to {
          transform: translateX(0);
          opacity: 1;
        }
      }

      @keyframes bounce {
        0%, 100% {
          transform: translateY(0);
        }
        50% {
          transform: translateY(-10px);
        }
      }

      @keyframes pulse {
        0%, 100% {
          transform: scale(1);
        }
        50% {
          transform: scale(1.05);
        }
      }

      @media (max-width: 768px) {
        .dashboard-container {
          padding: 1rem;
        }

        .dashboard-title {
          font-size: 2rem;
        }

        .charts-container {
          grid-template-columns: 1fr;
        }

        .sessions-grid {
          grid-template-columns: 1fr;
        }
      }
    </style>
    """
  end

  # Component for stat cards
  defp stat_card(assigns) do
    ~H"""
    <div class="stat-card">
      <div class="stat-icon"><%= @icon %></div>
      <div class="stat-value"><%= @value %></div>
      <div class="stat-label"><%= @label %></div>
    </div>
    """
  end

  # Component for WPM chart
  defp wpm_chart(assigns) do
    ~H"""
    <div class="chart-placeholder">
      <%= if Enum.empty?(@data) do %>
        <p style="text-align: center; color: #9ca3af; padding: 2rem;">
          No data yet. Complete more sessions to see your progress!
        </p>
      <% else %>
        <div class="simple-chart">
          <%= for point <- @data do %>
            <div class="chart-bar" style={"height: #{normalize_wpm(point.avg_wpm)}%; animation-delay: #{Enum.find_index(@data, fn p -> p == point end) * 0.1}s;"}>
              <div class="bar-label"><%= Float.round(point.avg_wpm, 0) %></div>
              <div class="bar-date"><%= format_date(point.date) %></div>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>

    <style>
      .simple-chart {
        display: flex;
        align-items: flex-end;
        justify-content: space-around;
        height: 300px;
        gap: 0.5rem;
        padding: 1rem;
      }

      .chart-bar {
        flex: 1;
        min-width: 40px;
        background: linear-gradient(to top, #667eea, #764ba2);
        border-radius: 8px 8px 0 0;
        position: relative;
        transition: transform 0.3s ease;
        animation: growUp 0.6s ease-out backwards;
      }

      .chart-bar:hover {
        transform: scaleY(1.05);
        filter: brightness(1.1);
      }

      .bar-label {
        position: absolute;
        top: -1.5rem;
        left: 50%;
        transform: translateX(-50%);
        font-size: 0.875rem;
        font-weight: 600;
        color: #667eea;
      }

      .bar-date {
        position: absolute;
        bottom: -2rem;
        left: 50%;
        transform: translateX(-50%) rotate(-45deg);
        font-size: 0.75rem;
        color: #6b7280;
        white-space: nowrap;
      }

      @keyframes growUp {
        from {
          transform: scaleY(0);
          opacity: 0;
        }
        to {
          transform: scaleY(1);
          opacity: 1;
        }
      }
    </style>
    """
  end

  # Component for frequency chart (heatmap style)
  defp frequency_chart(assigns) do
    ~H"""
    <div class="frequency-grid">
      <%= if Enum.empty?(@data) do %>
        <p style="text-align: center; color: #9ca3af; padding: 2rem;">
          No data yet. Start practicing to see your frequency!
        </p>
      <% else %>
        <%= for point <- @data do %>
          <div
            class="frequency-cell"
            style={"background: #{frequency_color(point.count)}; animation-delay: #{Enum.find_index(@data, fn p -> p == point end) * 0.02}s;"}
            title={"#{format_date(point.date)}: #{point.count} session(s)"}
          >
          </div>
        <% end %>
      <% end %>
    </div>

    <style>
      .frequency-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(20px, 1fr));
        gap: 4px;
        padding: 1rem;
      }

      .frequency-cell {
        aspect-ratio: 1;
        border-radius: 4px;
        transition: transform 0.2s ease;
        animation: popIn 0.3s ease-out backwards;
        cursor: pointer;
      }

      .frequency-cell:hover {
        transform: scale(1.2);
        box-shadow: 0 2px 8px rgba(0,0,0,0.2);
      }

      @keyframes popIn {
        from {
          transform: scale(0);
          opacity: 0;
        }
        to {
          transform: scale(1);
          opacity: 1;
        }
      }
    </style>
    """
  end

  # Component for session cards
  defp session_card(assigns) do
    ~H"""
    <div class="session-card">
      <div class="session-date">
        <%= format_datetime(@session.practiced_at) %>
      </div>
      <div class="session-metrics">
        <span class="session-metric">
          💬 <%= @session.word_count %> words
        </span>
        <span class="session-metric">
          ⚡ <%= @session.wpm %> WPM
        </span>
      </div>
      <div class="session-speech">
        "<%= String.slice(@session.speech_text, 0, 120) %><%= if String.length(@session.speech_text) > 120, do: "..." %>"
      </div>
    </div>
    """
  end

  # Helper functions
  defp format_number(num) when num >= 1_000_000 do
    "#{Float.round(num / 1_000_000, 1)}M"
  end

  defp format_number(num) when num >= 1_000 do
    "#{Float.round(num / 1_000, 1)}K"
  end

  defp format_number(num), do: to_string(num)

  defp normalize_wpm(wpm) do
    # Normalize WPM to 0-100% for chart display
    # Assuming typical speaking is 100-200 WPM
    min(100, max(20, wpm / 2))
  end

  defp frequency_color(count) do
    case count do
      0 -> "#e5e7eb"
      1 -> "#bfdbfe"
      2 -> "#93c5fd"
      3 -> "#60a5fa"
      _ -> "#3b82f6"
    end
  end

  defp format_date(date) when is_binary(date) do
    case Date.from_iso8601(date) do
      {:ok, d} -> Calendar.strftime(d, "%m/%d")
      _ -> date
    end
  end

  defp format_date(date), do: Calendar.strftime(date, "%m/%d")

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%B %d, %Y at %I:%M %p")
  end
end
