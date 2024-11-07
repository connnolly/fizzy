module Filter::Fields
  extend ActiveSupport::Concern

  INDEXES = %w[ most_active most_discussed most_boosted newest oldest popped ]

  class_methods do
    def default_fields
      { "indexed_by" => "most_active" }
    end
  end

  def assignments=(value)
    fields["assignments"] = value
  end

  def assignments
    fields["assignments"].to_s.inquiry
  end

  def indexed_by=(value)
    fields["indexed_by"] = value
  end

  def indexed_by
    (fields["indexed_by"] || default_fields["indexed_by"]).inquiry
  end

  private
    delegate :default_fields, to: :class, private: true
end
