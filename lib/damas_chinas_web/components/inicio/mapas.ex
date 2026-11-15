defmodule DamasChinasWeb.Inicio.Mapas do
  @moduledoc """
  Lista de mapas (ambientes) del fondo de la pantalla de inicio.

  Todos usan la misma imagen `fondo.webp`, pero cada uno le aplica un filtro
  de color de Tailwind distinto (girar el tono, saturar, aclarar), así el
  jardín parece otro lugar. El filtro se aplica al fondo de toda la pantalla
  y a la miniatura de la tarjeta "Mapa actual".

  Para agregar un mapa: copia una línea de `@mapas` y cambia nombre y filtro.
  """

  @mapas [
    %{nombre: "Jardín Celestial", filtro: ""},
    %{nombre: "Laguna de Jade", filtro: "-hue-rotate-60 saturate-125"},
    %{nombre: "Crepúsculo Violeta", filtro: "hue-rotate-40 saturate-125"},
    %{nombre: "Atardecer de Bambú", filtro: "hue-rotate-150 saturate-110 brightness-105"},
    %{nombre: "Luna de Plata", filtro: "saturate-40 brightness-110 contrast-110"}
  ]

  @doc "Cuántos mapas hay."
  def total, do: length(@mapas)

  @doc "El mapa número `i` (empieza en 0)."
  def obtener(i), do: Enum.at(@mapas, rem(i, total()))

  @doc "Índice del mapa siguiente (al llegar al último vuelve al primero)."
  def siguiente(i), do: rem(i + 1, total())

  @doc "Índice del mapa anterior (antes del primero va al último)."
  def anterior(i), do: rem(i - 1 + total(), total())
end
