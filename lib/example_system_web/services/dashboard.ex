defmodule ExampleSystemWeb.Services.Dashboard do
  use ExampleSystemWeb, :live_view

  @impl true
  def mount(_session, _params, socket) do
    if connected?(socket), do: :timer.send_interval(100, :refresh_state)
    {:ok, refresh_state(assign(socket, response: nil))}
  end

  @impl true
  def handle_event("add_service", %{"service" => %{"name" => name}}, socket) do
    if name != "", do: ExampleSystem.Service.start_in_cluster(name)
    {:noreply, refresh_state(socket)}
  end

  def handle_event("invoke_" <> name, _params, socket) do
    {:noreply, assign(socket, response: ExampleSystem.Service.invoke(name))}
  end

  @impl true
  def handle_info(:refresh_state, socket), do: {:noreply, refresh_state(socket)}

  defp refresh_state(socket), do: assign(socket, nodes: nodes())

  defp nodes() do
    services =
      Enum.group_by(
        for({name, pid} <- Swarm.registered(), do: %{name: name, node: node(pid)}),
        & &1.node,
        & &1.name
      )

    Node.list([:this, :visible])
    |> Stream.map(&%{name: &1, services: Enum.sort(Map.get(services, &1, []))})
    |> Enum.sort_by(& &1.name)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-4">
      <div>
        <%= form_tag("", class: "form", "phx-submit": "add_service") do %>
          <%= text_input(:service, :name, autofocus: true) %>
        <% end %>
      </div>

      <ul class="mt-4">
        <%= Enum.map(@nodes, fn node -> %>
          <li>
            <%= node.name %>
            <ul class="list-inside">
              <%= Enum.map(node.services, fn service -> %>
                <li class="list-disc">
                  <%= link(service, to: "#", "phx-click": "invoke_#{service}", class: "text-blue-700 underline") %>
                </li>
              <% end) %>
            </ul>
          </li>
        <% end) %>
      </ul>

      <%= if @response != nil do %>
        <div class="mt-4"><%= @response %></div>
      <% end %>
    </div>
    """
  end
end
