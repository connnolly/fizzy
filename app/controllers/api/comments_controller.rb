class Api::CommentsController < Api::BaseController
  def create
    card = current_user.accessible_cards.find_by!(number: params[:card_id])
    comment = card.comments.create!(creator: current_user, body: params[:body])
    render json: { id: comment.id, body: comment.body&.to_plain_text }, status: :created
  end
end
