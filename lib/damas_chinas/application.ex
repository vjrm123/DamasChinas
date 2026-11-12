defmodule DamasChinas.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DamasChinasWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:damas_chinas, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: DamasChinas.PubSub},
      # Start a worker by calling: DamasChinas.Worker.start_link(arg)
      # {DamasChinas.Worker, arg},
      # Start to serve requests, typically the last entry
      DamasChinasWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DamasChinas.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DamasChinasWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
