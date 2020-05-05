require 'test_helper'

class TagsControllerTest < ActionDispatch::IntegrationTest
  test "it works!" do
    tag = tags(:pizza)
    get tag_url(tag)
    assert_response 200
  end
end
