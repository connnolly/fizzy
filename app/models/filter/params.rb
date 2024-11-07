module Filter::Params
  extend ActiveSupport::Concern

  KNOWN_PARAMS = [ :indexed_by, :assignments, bucket_ids: [], assignee_ids: [], tag_ids: [] ]

  included do
    after_initialize :derive_params
  end

  def to_params
    ActionController::Parameters.new(params).permit(*KNOWN_PARAMS).tap do |params|
      params[:filter_id] = id if persisted?
    end
  end

  private
    # `derive_params` stores a denormalized version of the filter in `params` to
    #    1) Enforce uniqueness via db constraints
    #    2) Look up identical filters by a single column
    #    3) Easily turn all filter params into a query string
    def derive_params
      derive_params_from_resource_ids
      derive_params_from_fields
      params.compact_blank!
    end
    alias_method :derived_params, :derive_params

    def derive_params_from_resource_ids
      params["tag_ids"] = tags.ids
      params["bucket_ids"] = buckets.ids
      params["assignee_ids"] = assignees.ids
    end

    def derive_params_from_fields
      self.params.merge! fields.reject { |k, v| default_fields[k] == v }
    end
end
