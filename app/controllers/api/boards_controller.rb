class Api::BoardsController < Api::BaseController
  def index
    boards = current_user.boards.includes(:columns).map do |b|
      {
        id: b.id,
        name: b.name,
        columns: all_columns_for(b).map { |c| { id: c[:id], name: c[:name] } }
      }
    end
    render json: boards
  end

  def show
    board = current_user.boards.find(params[:id])
    render json: {
      id: board.id,
      name: board.name,
      columns: all_columns_with_cards(board)
    }
  end

  private

  def all_columns_for(board)
    [
      { id: "not_now", name: "Not now" },
      { id: "maybe", name: "Maybe?" }
    ] +
    board.columns.order(:position).map { |c| { id: c.id, name: c.name } } +
    [
      { id: "done", name: "Done" }
    ]
  end

  def all_columns_with_cards(board)
    cards = board.cards.published.includes(:tags, :assignees, :not_now, :closure, :column)

    [
      {
        id: "not_now",
        name: "Not now",
        position: -2,
        cards: cards.postponed.map { |c| card_summary(c) }
      },
      {
        id: "maybe",
        name: "Maybe?",
        position: -1,
        cards: cards.awaiting_triage.map { |c| card_summary(c) }
      }
    ] +
    board.columns.order(:position).map do |col|
      {
        id: col.id,
        name: col.name,
        position: col.position,
        cards: cards.where(column: col).map { |c| card_summary(c) }
      }
    end +
    [
      {
        id: "done",
        name: "Done",
        position: 999,
        cards: cards.closed.map { |c| card_summary(c) }
      }
    ]
  end

  def card_summary(card)
    {
      number: card.number,
      title: card.title,
      tags: card.tags.pluck(:title),
      assignees: card.assignees.map { |u| u.identity&.email_address || u.name }
    }
  end
end
