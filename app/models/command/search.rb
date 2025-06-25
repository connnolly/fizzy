class Command::Search < Command
  store_accessor :data, :terms

  def title
    "Search '#{terms}'"
  end

  def execute
    redirect_to search_path(q: terms)
  end
end
