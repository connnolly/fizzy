class Entropy < ApplicationRecord
  belongs_to :container, polymorphic: true

  after_commit -> { container.cards.touch_all }

  class << self
    def default
      Account.sole.default_entropy
    end
  end
end
