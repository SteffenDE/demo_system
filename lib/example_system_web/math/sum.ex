defmodule ExampleSystemWeb.Math.Sum do
  use ExampleSystemWeb, :live_view

  @impl true
  def mount(_session, _params, socket), do: {:ok, assign(socket, operations: [], data: data())}

  @impl true
  def handle_event("submit", %{"data" => %{"to" => str_input}}, socket),
    do: {:noreply, start_sum(socket, str_input)}

  @impl true
  def handle_info({:sum, pid, sum}, socket),
    do: {:noreply, update(socket, :operations, &set_result(&1, pid, sum))}

  def handle_info({:DOWN, _ref, :process, pid, _reason}, socket),
    do: {:noreply, update(socket, :operations, &set_result(&1, pid, :error))}

  defp start_sum(socket, str_input) do
    operation =
      case Integer.parse(str_input) do
        :error ->
          %{pid: nil, input: str_input, result: "invalid input"}

        {_input, remaining} when byte_size(remaining) > 0 ->
          %{pid: nil, input: str_input, result: "invalid input"}

        # {input, ""} when input <= 0 ->
        #   %{pid: nil, input: input, result: "invalid input"}

        {input, ""} ->
          do_start_sum(input)
      end

    socket |> update(:operations, &[operation | &1]) |> assign(:data, data())
  end

  defp do_start_sum(input) do
    {:ok, pid} = ExampleSystem.Math.sum(input)
    %{pid: pid, input: input, result: :calculating}
  end

  defp set_result(operations, pid, result) do
    case Enum.split_with(operations, &match?(%{pid: ^pid, result: :calculating}, &1)) do
      {[operation], rest} -> [%{operation | result: result} | rest]
      _other -> operations
    end
  end

  defp data(), do: Ecto.Changeset.cast({%{}, %{to: :integer}}, %{to: ""}, [:to])

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-4">
      <%= form_for(@data, "", ["phx-submit": "submit", as: :data], fn f -> %>
        <%= number_input(f, :to, autofocus: true) %>
      <% end) %>
      <br/>

      <div>
        <%= for operation <- @operations do %>
          <div>∑(1..<%= operation.input %>) = <%= operation.result %></div>
        <% end %>
      </div>
    </div>
    """
  end
end
