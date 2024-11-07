module FiltersHelper
  def buckets_filter_text(filter)
    if filter.buckets.present?
      filter.buckets.map(&:name).to_choice_sentence
    else
      "all projects"
    end
  end

  def assignments_filter_text(filter)
    if filter.assignees.present?
      "assigned to #{filter.assignees.map(&:name).to_choice_sentence}"
    elsif filter.assignments.unassigned?
      "assigned to no one"
    else
      "assigned to anyone"
    end
  end

  def tags_filter_text(filter)
    if filter.tags.present?
      filter.tags.map(&:hashtag).to_choice_sentence
    else
      "any tag"
    end
  end
end
