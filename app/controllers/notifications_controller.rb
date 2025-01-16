class NotificationsController < ApplicationController
  def index
    @read = Current.user.notifications.read.ordered
    @unread = Current.user.notifications.unread.ordered
  end
end
