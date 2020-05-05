test "PATCH /api/trucks/1 updates the most recent known location" do
  truck = food_trucks(:pizza)
  lat, lng = [37.782267, -122.391248]
  patch api_truck_url(truck), params: { truck: { location: [lat, lng] } }

  assert_response 200
  assert_equal [lat, lng], response.fetch(:location)
end

test "GET /api/trucks/1 returns the most recent known location" do
  truck = food_trucks(:pizza)
  lat, lng = [37.782267, -122.391248]
  truck.set_location(latitude: lat, longitude: lng)

  get api_truck_url(truck)
  assert_response 200
  assert_equal [lat, lng], response.fetch(:location)
end

test "GET /api/trucks with `near` returns the distance in the response" do
  truck = food_trucks(:pizza)
  lat, lng = [37.782267, -122.391248]
  truck.set_location(latitude: lat, longitude: lng)

  get api_trucks_url, params: {near: [lat + 0.1, lng + 0.1]}
  assert_response 200

  refute_empty response
  response.each do |entry|
    assert_predicate entry[:distance], :present?
    assert entry[:distance].between?(0.1, 50)
  end
end

test "Omitting the near lat/lng omits the distance from the response" do
  truck = food_trucks(:pizza)
  lat, lng = [37.782267, -122.391248]
  truck.set_location(latitude: lat, longitude: lng)

  get api_trucks_url
  assert_response 200

  refute_empty response
  response.each do |entry|
    refute entry.key?(:distance), "distance should be omitted when `near` isn't provided"
  end
end
