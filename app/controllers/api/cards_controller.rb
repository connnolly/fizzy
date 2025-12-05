class Api::CardsController < Api::BaseController
  def show
    card = find_card
    render json: {
      number: card.number,
      title: card.title,
      description: card.description&.to_plain_text,
      status: card.status,
      board: { id: card.board.id, name: card.board.name },
      column: card.column ? { id: card.column.id, name: card.column.name } : nil,
      tags: card.tags.pluck(:title),
      assignees: card.assignees.map { |u| u.identity&.email_address || u.name },
      comments: card.comments.chronologically.includes(:creator).map do |c|
        {
          id: c.id,
          author: c.creator.identity&.email_address || c.creator.name,
          body: c.body&.to_plain_text,
          created_at: c.created_at.iso8601
        }
      end,
      created_at: card.created_at.iso8601,
      updated_at: card.updated_at.iso8601
    }
  end

  def create
    board = current_user.boards.find(params[:board_id])
    column = params[:column_id].present? ? board.columns.find(params[:column_id]) : nil

    card = board.cards.create!(
      creator: current_user,
      title: params[:title],
      description: params[:description],
      status: "drafted"
    )

    # If a column is specified, triage the card into it
    card.triage_into(column) if column

    render json: { number: card.number, title: card.title, status: card.status }, status: :created
  end

  def update
    card = find_card
    card.update!(card_params)
    render json: { number: card.number, title: card.title, status: card.status }
  end

  def move
    card = find_card
    column = Column.find(params[:column_id])

    # Verify the column belongs to a board the user can access
    unless current_user.boards.exists?(column.board_id)
      render json: { error: "Column not accessible" }, status: :forbidden
      return
    end

    card.triage_into(column)
    render json: { number: card.number, column: column.name }
  end

  private

  def find_card
    current_user.accessible_cards.find_by!(number: params[:id])
  end

  def card_params
    params.permit(:title, :description, :status)
  end
end
