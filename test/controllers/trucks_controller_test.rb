require 'test_helper'

class TrucksControllerTest < ActionDispatch::IntegrationTest
  test "it works!" do
    get root_url
    assert_response 200
  end
end
