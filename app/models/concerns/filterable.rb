module Filterable
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :filters

    after_update { filters.touch_all }
    before_destroy :remove_from_filters
  end

  private
    def remove_from_filters
      filters.each { |filter| filter.resource_removed self }
    end
end
