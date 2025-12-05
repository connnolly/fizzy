class Api::SearchController < Api::BaseController
  def index
    query = params[:q].to_s.strip
    if query.blank?
      render json: { error: "Query parameter 'q' is required" }, status: :bad_request
      return
    end

    # Search across title, description (ActionText), and comments (ActionText)
    pattern = "%#{query}%"

    # Find card IDs that match in title
    title_matches = current_user.accessible_cards.published
      .where("cards.title LIKE ?", pattern).pluck(:id)

    # Find card IDs that match in description (ActionText)
    desc_matches = current_user.accessible_cards.published
      .joins(:rich_text_description)
      .where("action_text_rich_texts.body LIKE ?", pattern).pluck(:id)

    # Find card IDs that have comments matching (ActionText)
    comment_matches = current_user.accessible_cards.published
      .joins(comments: :rich_text_body)
      .where("action_text_rich_texts.body LIKE ?", pattern).pluck(:id)

    all_ids = (title_matches + desc_matches + comment_matches).uniq

    cards = current_user.accessible_cards
      .published
      .includes(:board, :column, :tags)
      .where(id: all_ids)
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
