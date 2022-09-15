defmodule LoadControl.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {PartitionSupervisor,
       child_spec: DynamicSupervisor, name: LoadControl.DynamicSupervisors, partitions: 1000},
      LoadControl.Stats,
      LoadControl.SchedulerMonitor,
      LoadControl
    ]

    opts = [strategy: :one_for_one, name: LoadControl.Supervisor]
    Supervisor.init(children, opts)
  end
end
