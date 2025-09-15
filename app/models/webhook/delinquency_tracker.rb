class Webhook::DelinquencyTracker < ApplicationRecord
  DELINQUENCY_THRESHOLD = 10
  CHECK_INTERVAL = 1.hour

  belongs_to :webhook

  def record_delivery_of(delivery)
    if delivery.succeeded?
      reset
    else
      mark_first_failure_time if consecutive_failures_count.zero?
      increment!(:consecutive_failures_count)

      webhook.deactivate if delinquent?
    end
  end

  private
    def reset
      update_columns consecutive_failures_count: 0, first_failure_at: nil
    end

    def mark_first_failure_time
      update_columns first_failure_at: Time.current
    end

    def delinquent?
      enough_time_passed? && (consecutive_failures_count >= DELINQUENCY_THRESHOLD)
    end

    def enough_time_passed?
      if first_failure_at
        first_failure_at.before?(CHECK_INTERVAL.ago)
      else
        false
      end
    end
end
