module Card::Entropic
  extend ActiveSupport::Concern

  included do
    scope :entropic_by, ->(period_name) do
      left_outer_joins(collection: :entropy_configuration)
        .where("last_active_at <= DATETIME('now', '-' || COALESCE(entropy_configurations.#{period_name}, ?) || ' seconds')",
          Entropy::Configuration.default.public_send(period_name))
    end

    scope :stagnated, -> { doing.entropic_by(:auto_reconsider_period) }
    scope :due_to_be_closed, -> { considering.entropic_by(:auto_close_period) }
    delegate :auto_close_period, :auto_reconsider_period, to: :collection
  end

  class_methods do
    def auto_close_all_due
      due_to_be_closed.find_each do |card|
        card.close(user: User.system, reason: "Closed")
      end
    end

    def auto_reconsider_all_stagnated
      stagnated.find_each(&:reconsider)
    end
  end

  def entropy
    Card::Entropy.for(self)
  end

  def entropic?
    entropy.present?
  end
end
