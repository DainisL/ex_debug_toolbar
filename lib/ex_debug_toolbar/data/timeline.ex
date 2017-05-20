defmodule ExDebugToolbar.Data.Timeline do
  alias ExDebugToolbar.Data.Timeline

  defstruct [
    events: [],
    duration: 0,
    queue: []
  ]

  def add_event(%Timeline{} = timeline, name, duration) do
    start_event(timeline, name) |> finish_event(name, duration: duration)
  end

  def start_event(%Timeline{} = timeline, name) do
    event = %Timeline.Event{name: name, started_at: System.monotonic_time()}
    %{timeline | queue: [event | timeline.queue]}
  end

  def finish_event(timeline, name, opts \\ [])
  def finish_event(%Timeline{queue: [%{name: name} = event]} = timeline, name, opts) do
    events = timeline.events
    finished_event = update_duration(event, opts[:duration])
    %{timeline |
      queue: [],
      events: [finished_event | events],
      duration: finished_event.duration + timeline.duration
    }
  end
  def finish_event(%Timeline{queue: [%{name: name} = event | [parent | rest]]} = timeline, name, opts) do
    finished_event = update_duration(event, opts[:duration])
    new_parent = %{parent | events: [finished_event | parent.events]}
    %{timeline | queue: [new_parent | rest]}
  end
  def finish_event(_timeline, name, _opts), do: raise "the event #{name} is not open"

  defp update_duration(event, nil) do
    duration = System.monotonic_time() - event.started_at
    update_duration(event, duration)
  end
  defp update_duration(event, duration), do: %{event | duration: duration}
end

alias ExDebugToolbar.Data.{Collection, Timeline, Timeline.Action}

defimpl Collection, for: Timeline do
  def change(timeline, %Action{action: :start_event, event_name: name}) do
    Timeline.start_event(timeline, name)
  end

  def change(timeline, %Action{action: :finish_event, event_name: name, duration: duration}) do
    Timeline.finish_event(timeline, name, duration: duration)
  end

  def change(timeline, %Action{action: :add_event, event_name: name, duration: duration}) do
    Timeline.add_event(timeline, name, duration)
  end
end
