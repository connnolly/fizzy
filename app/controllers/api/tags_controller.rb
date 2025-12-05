class Api::TagsController < Api::BaseController
  def index
    tags = Current.account.tags.alphabetically.map { |t| { id: t.id, title: t.title } }
    render json: tags
  end

  def add_to_card
    card = current_user.accessible_cards.find_by!(number: params[:card_id])
    tag = Current.account.tags.find_or_create_by!(title: params[:title].downcase)

    unless card.tagged_with?(tag)
      card.taggings.create!(tag: tag)
    end

    render json: { card: card.number, tag: tag.title }, status: :created
  end

  def remove_from_card
    card = current_user.accessible_cards.find_by!(number: params[:card_id])
    tag = Current.account.tags.find_by!(title: params[:title].downcase)
    card.taggings.destroy_by(tag: tag)
    render json: { card: card.number, removed_tag: tag.title }
  end
end
