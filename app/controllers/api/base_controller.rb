class Api::BaseController < ActionController::API
  before_action :authenticate_token!
  before_action :set_current_context

  private

  def authenticate_token!
    token = request.headers["Authorization"]&.remove("Bearer ")
    if ENV["CLAUDE_API_TOKEN"].blank?
      render json: { error: "CLAUDE_API_TOKEN not configured" }, status: :service_unavailable
      return
    end
    unless ActiveSupport::SecurityUtils.secure_compare(token.to_s, ENV["CLAUDE_API_TOKEN"].to_s)
      head :unauthorized
    end
  end

  def set_current_context
    identity = Identity.find_by(email_address: ENV["CLAUDE_USER_EMAIL"])
    unless identity
      render json: { error: "CLAUDE_USER_EMAIL '#{ENV['CLAUDE_USER_EMAIL']}' not found" }, status: :service_unavailable
      return
    end

    user = identity.users.where(active: true).first
    unless user
      render json: { error: "No active user found for #{ENV['CLAUDE_USER_EMAIL']}" }, status: :service_unavailable
      return
    end

    Current.user = user
    Current.account = user.account
  end

  def current_user
    Current.user
  end
end
