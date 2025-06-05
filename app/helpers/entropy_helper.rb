module EntropyHelper
  def entropy_auto_close_options
    [ 3, 7, 11, 30, 90, 365 ]
  end

  def entropy_bubble_options_for(card)
    {
      daysBeforeReminder: card.entropy.days_before_reminder,
      closesAt: card.entropy.auto_clean_at.iso8601,
      action: card_entropy_action(card)
    }
  end

  def stalled_bubble_options_for(card)
    if card.last_activity_spike_at
      {
        stalledAfterDays: card.entropy.days_before_reminder,
        lastActivitySpikeAt: card.last_activity_spike_at.iso8601
      }
    end
  end

  def card_entropy_action(card)
    if card.doing?
      "Falls Back"
    elsif card.considering?
      "Closes"
    end
  end
end
