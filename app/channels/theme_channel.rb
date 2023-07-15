class ThemeChannel < ApplicationCable::Channel
  def subscribed
    stream_from "theme_change:#{params[:one_pager_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
