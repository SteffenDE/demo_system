defmodule ExampleSystemWeb.Load.Dashboard do
  use ExampleSystemWeb, :live_view

  @impl true
  def mount(_session, _params, socket) do
    {:ok,
     assign(socket,
       load: changeset(LoadControl.load()),
       schedulers: changeset(:erlang.system_info(:schedulers_online)),
       metrics: ExampleSystem.Metrics.subscribe(),
       highlighted: nil
     )}
  end

  @impl true
  def handle_event("change_load", %{"load_data" => %{"value" => load}}, socket) do
    with {load, ""} when load >= 0 <- Integer.parse(load) do
      Task.start_link(fn -> LoadControl.change_load(load) end)
      {:noreply, assign(socket, :load, changeset(load))}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("change_schedulers", %{"scheduler_data" => %{"value" => schedulers}}, socket) do
    with {schedulers, ""} when schedulers > 0 <- Integer.parse(schedulers) do
      Task.start_link(fn -> LoadControl.change_schedulers(schedulers) end)
      {:noreply, assign(socket, :schedulers, changeset(schedulers))}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("reset", _params, socket) do
    me = self()

    Task.start_link(fn ->
      ExampleSystem.Metrics.subscribe()

      LoadControl.change_load(0)

      fn -> ExampleSystem.Metrics.await_next() end
      |> Stream.repeatedly()
      |> Stream.drop_while(&(&1.jobs_rate > 0))
      |> Enum.take(1)

      LoadControl.change_schedulers(1)
      Process.sleep(1000)

      send(me, :clear_history)
    end)

    {:noreply, socket}
  end

  def handle_event("highlight_" <> what, _params, socket) do
    highlighted = if socket.assigns.highlighted == what, do: nil, else: what
    {:noreply, assign(socket, :highlighted, highlighted)}
  end

  @impl true
  def handle_info({:metrics, metrics}, socket), do: {:noreply, assign(socket, :metrics, metrics)}

  def handle_info(:clear_history, socket) do
    ExampleSystem.Metrics.clear_history()

    {:noreply,
     assign(socket,
       load: changeset(LoadControl.load()),
       schedulers: changeset(:erlang.system_info(:schedulers_online))
     )}
  end

  defp changeset(value),
    do: Ecto.Changeset.cast({%{}, %{value: :integer}}, %{value: value}, [:value])

  defp data_points(graph) do
    graph.data_points
    |> Stream.map(&"#{x(&1.x)},#{y(&1.y)}")
    |> Enum.join(" ")
  end

  defp graph(assigns) do
    ~H"""
    <svg viewBox={"0 0 #{graph_width() + 150} #{graph_height() + 150}"} height="500" class="chart">
    <style>
    .title { font-size: 30px;}
    </style>

    <g transform="translate(100, 100)">
    <%# title %>
    <g stroke="black">
      <text class="title" text-anchor="middle" dominant-baseline="central" x="300" y="-50" fill="black">
        <%= @title %>
      </text>
    </g>

    <%# legends %>
    <%= for legend <- @graph.legends do %>
      <g stroke="black">
        <text text-anchor="end" dominant-baseline="central" x="-20" y={y(legend.at)} fill="black">
          <%= legend.title %>
        </text>
      </g>

      <g stroke-width="1" stroke="gray" stroke-dasharray="4">
        <line x1="0" x2={graph_width()} y1={y(legend.at)} y2={y(legend.at)} />
      </g>
    <% end %>

    <%# axes %>
    <g stroke-width="2" stroke="black">
      <line x1="0" x2="0" y1="0" y2={graph_height()} />
      <line x1="0" x2={graph_width()} y1={graph_height()} y2={graph_height()} />
    </g>

    <%# data points %>
    <polyline fill="none" stroke="#0074d9" stroke-width="2" points={data_points(@graph)} />
    </g>
    </svg>
    """
  end

  defp x(relative_x), do: min(round(relative_x * graph_width()), graph_width())
  defp y(relative_y), do: graph_height() - min(round(relative_y * graph_height()), graph_height())

  defp graph_width(), do: 600
  defp graph_height(), do: 500

  defp highlight_class(a, a), do: "bg-gray-200"
  defp highlight_class(_, _), do: ""

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col p-4">
      <div class="mx-auto">
        <%= form_for(@load, "", ["phx-submit": "change_load", as: :load_data], fn f -> %>
          <%= number_input(f, :value, autofocus: true) %>
        <% end) %>

        <div>jobs (<span phx-click="highlight_memory" class={highlight_class(@highlighted, "memory")}><%= @metrics.memory_usage %> MB</span>)</div>

        <%= form_for(@schedulers, "", ["phx-submit": "change_schedulers", as: :scheduler_data], fn f -> %>
          <%= number_input(f, :value, autofocus: true) %>
        <% end) %>
        <div>schedulers</div>
      </div>

      <input type="button" value="reset" phx-click="reset"/>

      <div class="flex mx-auto">
        <div phx-click="highlight_jobs_graph" class={highlight_class(@highlighted, "jobs_graph")}>
          <.graph graph={@metrics.jobs_graph} title="successful jobs/sec" />
        </div>

        <div phx-click="highlight_scheduler_graph" class={highlight_class(@highlighted, "scheduler_graph")}>
          <.graph graph={@metrics.scheduler_graph} title="scheduler usage" />
        </div>
      </div>
    </div>

    """
  end
end
