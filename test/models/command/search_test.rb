require "test_helper"

class Command::SearchTest < ActionDispatch::IntegrationTest
  include CommandTestHelper

  test "redirect to the user perma" do
    result = execute_command "/search something"

    assert_equal search_path(q: "something"), result.url
  end
end
