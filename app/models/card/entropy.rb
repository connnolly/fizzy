class Card::Entropy
  attr_reader :card, :auto_clean_period

  class << self
    def for(card)
      return unless card.last_active_at

      if card.considering?
        new(card, card.auto_close_period)
      elsif card.doing?
        new(card, card.auto_reconsider_period)
      end
    end
  end

  def initialize(card, auto_clean_period)
    @card = card
    @auto_clean_period = auto_clean_period
  end

  def auto_clean_at
    card.last_active_at + auto_clean_period
  end

  def days_before_reminder
    (auto_clean_period * 0.25).round
  end
end
