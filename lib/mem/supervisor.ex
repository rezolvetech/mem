defmodule Mem.Supervisor do
  use Supervisor

  def start_link([names, module]) do
    :ets.new(names[:proxy_ets], [:set, :public, :named_table, read_concurrency: true])
    :ets.new(names[:data_ets],  [:set, :public, :named_table, write_concurrency: true])
    :ets.new(names[:ttl_ets],   [:set, :public, :named_table, write_concurrency: true])
    Supervisor.start_link(__MODULE__, [names, module], name: names[:sup_name])
  end

  def init([names, module]) do
    [ worker(Mem.Proxy, [names]),
      worker(Mem.TTLCleaner, [names, module]),
      supervisor(Mem.Worker.Supervisor, [names]),
    ] |> supervise(strategy: :one_for_all)
  end
end
