defmodule LoadControl.Application do
  use Application

  def start(_type, _args) do
    children = [
      {PartitionSupervisor,
       child_spec: DynamicSupervisor, name: LoadControl.DynamicSupervisors, partitions: 1000},
      LoadControl.Stats,
      LoadControl.SchedulerMonitor,
      LoadControl
    ]

    opts = [strategy: :one_for_one, name: LoadControl.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
