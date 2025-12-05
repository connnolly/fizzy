class Api::BoardsController < Api::BaseController
  def index
    boards = current_user.boards.includes(:columns).map do |b|
      {
        id: b.id,
        name: b.name,
        columns: b.columns.order(:position).map { |c| { id: c.id, name: c.name } }
      }
    end
    render json: boards
  end

  def show
    board = current_user.boards.find(params[:id])
    render json: {
      id: board.id,
      name: board.name,
      columns: board.columns.order(:position).includes(:cards).map do |col|
        {
          id: col.id,
          name: col.name,
          position: col.position,
          cards: col.cards.published.includes(:tags, :assignees).map { |c| card_summary(c) }
        }
      end
    }
  end

  private

  def card_summary(card)
    {
      number: card.number,
      title: card.title,
      tags: card.tags.pluck(:name),
      assignees: card.assignees.map { |u| u.identity&.email_address || u.name }
    }
  end
end
