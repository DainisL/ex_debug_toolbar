defmodule ExDebugToolbar.ToolbarView do
  use ExDebugToolbar.Web, :view

  def format_native_time(time) do
    time
    |> System.convert_time_unit(:native, :micro_seconds)
    |> time_to_string
  end

  defp time_to_string(time) when time > 1000, do: [time |> div(1000) |> Integer.to_string, "ms"]
  defp time_to_string(time), do: [Integer.to_string(time), "µs"]
end
