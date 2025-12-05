class Api::SearchController < Api::BaseController
  def index
    query = params[:q].to_s.strip
    if query.blank?
      render json: { error: "Query parameter 'q' is required" }, status: :bad_request
      return
    end

    cards = current_user.accessible_cards
      .published
      .includes(:board, :column, :tags)
      .where("title LIKE :q", q: "%#{query}%")
      .limit(params[:limit]&.to_i || 20)

    results = cards.map do |c|
      {
        number: c.number,
        title: c.title,
        board: { id: c.board.id, name: c.board.name },
        column: c.column&.name,
        tags: c.tags.pluck(:title)
      }
    end

    render json: results
  end
end
