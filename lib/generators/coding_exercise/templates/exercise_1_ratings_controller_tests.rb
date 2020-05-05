
test "Rating a truck with 0 ratings sets a rating" do
  user = users(:harry)
  truck = food_trucks(:pizza)


  assert_nil truck.rating

  post api_truck_ratings_url(truck),
    params: { rating: 4 },
    headers: authorization_params(user)

  assert_equal 4, truck.rating
end

test "Rating a truck with a rating changes the rating" do
  truck = food_trucks(:pizza)

  rachel = users(:rachel)
  post api_truck_ratings_url(truck),
    params: { rating: 2 },
    headers: authorization_params(rachel)

  harry = users(:harry)
  post api_truck_ratings_url(truck),
    params: { rating: 4 },
    headers: authorization_params(harry)

  assert_equal 3, truck.rating
end

test "Can't rate if unauthenticated" do
  truck = food_trucks(:pizza)

  post api_truck_ratings_url(truck),
    params: { rating: 2 }

  assert_equal 401, response.status
end
