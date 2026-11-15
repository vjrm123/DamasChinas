defmodule DamasChinas.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DamasChinasWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:damas_chinas, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: DamasChinas.PubSub},
      # Registry: clave unica = codigo de sala  
      {Registry, keys: :unique, name: DamasChinas.SalaRegistry},
      # DynamicSupervisor: arranca/para GameServers en caliente
      {DynamicSupervisor, name: DamasChinas.SalaSupervisor, strategy: :one_for_one},
      DamasChinasWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: DamasChinas.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    DamasChinasWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
