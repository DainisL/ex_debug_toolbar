defmodule ExDebugToolbar.ToolbarViewTest do
  use ExUnit.Case, async: true
  alias ExDebugToolbar.Request
  alias ExDebugToolbar.Data.{LogEntry, Timeline}
  alias Phoenix.View
  alias ExDebugToolbar.ToolbarView
  alias ExDebugToolbar.Breakpoint

  test "it renderns toolbar without errors" do
    assert %Request{} |> render |> is_bitstring
  end

  test "it renders toolbar with logs without errors" do
    request = %Request{logs: [%LogEntry{
      level: :info,
      message: ["GET", 32, "/"],
      timestamp: {{2017, 6, 1}, {21, 44, 11, 482}}
    }]}
    assert request |> render |> is_bitstring
  end

  test "it renders toolbar with ecto queries without errors" do
    log_entry = %Ecto.LogEntry{
      ansi_color: :cyan,
      decode_time: 40929,
      params: [1],
      query: "select * from users",
      query_time: 1550583,
      queue_time: 205640,
      source: "users",
      result: {:ok, %Postgrex.Result{
        columns: ["id", "name", "inserted_at", "updated_at"],
        command: :select,
        connection_id: 2551,
        num_rows: 1,
      }}
    }
    duration = 15000
    request = %Request{ecto: [{log_entry, duration, :inline}]}
    assert request |> render |> is_bitstring
  end

  test "it renders toolbar with timeline" do
    timeline = %Timeline{
      duration: 50,
      events: [%Timeline.Event{
        name: "controller.call",
        duration: 5,
        events: [%Timeline.Event{
          name: "controller.render",
          duration: 7,
          events: [%Timeline.Event{
            name: "template#app.html",
            duration: 10
          }]
        }]
      }]
    }
    request = %Request{timeline: timeline}
    assert request |> render |> is_bitstring
  end

  test "it renders toolbar with breakpoints" do
    breakpoint = %Breakpoint{
      id: 1,
      pid: self(),
      line: 5,
      file: "test.ex",
      code_snippet: [{"a = [1, 2]", 5}],
      env: __ENV__,
      binding: binding(),
      inserted_at: NaiveDateTime.utc_now
    }
    assert %Request{} |> render(breakpoints: [breakpoint]) |> is_bitstring
  end

  defp render(request, opts \\ []) do
    assigns = [
      request: request,
      breakpoints: Keyword.get(opts, :breakpoints, [])
    ]
    View.render_to_string ToolbarView, "show.html", assigns
  end
end
