defmodule ExDebugToolbar.Phoenix.Instrumenter do
  alias ExDebugToolbar.Toolbar
  def phoenix_controller_call(:start, _, %{conn: %{private: private}}) do
    %{phoenix_controller: controller, phoenix_action: action} = private
    event_name = "#{to_string(controller)}:#{to_string(action)}"
    Toolbar.start_event(event_name)
    event_name
  end

  def phoenix_controller_call(:stop, _diff, event_name) do
    Toolbar.finish_event(event_name)
  end

  def phoenix_controller_render(:start, _, %{template: template}) do
    Toolbar.start_event(template)
    template
  end

  def phoenix_controller_render(:stop, _diff, template) do
    Toolbar.finish_event(template)
  end
end
