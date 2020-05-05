require "test_helper"

class Api::TrucksControllerTest < ActionDispatch::IntegrationTest

  test "GET /api/trucks works" do
    get api_trucks_url

    assert_response 200
    assert_same_elements FoodTruck.all.map(&:to_h), response
  end

  test "GET /api/trucks/1 works" do
    truck = food_trucks(:pizza)
    get api_truck_url(truck)

    assert_response 200
    assert_equal truck.to_h, response
  end

  test "A truck has a NULL rating without rating" do
    truck = food_trucks(:pizza)
    get api_truck_url(truck)
    assert_response 200
    assert_nil response[:rating]
  end

  test "GET returns rating for rated truck" do
    # TODO give the truck a 5-star rating

    truck = food_trucks(:pizza3)
    get api_truck_url(truck)
 
    assert_response 200
    assert_equal "5.0", response[:rating]
  end

  test "Decimals should be rounded to half a star when multiple ratings exist" do
    # TODO give the truck an average 3.333-star rating
    # Maybe 5,3,2?

    truck = food_trucks(:pizza2)
    get api_truck_url(truck)
    assert_response 200
    assert_equal "3.5", response[:rating]
  end

  # EXERCISE 2 - DO NOT DELETE THIS LINE

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


  # EXERCISE 3 - DO NOT DELETE THIS LINE

  test "GET /api/trucks returns all currently open trucks with open=true" do
    truck = food_trucks(:pizza)
    truck.update(open_sunday: true, opens_at_hour: 11, closes_at_hour: 23)

    Timecop.freeze("July 20, 1969 1:18 PM PST") do
      assert_predicate truck, :open?

      get api_trucks_url, params: { open: true }
      assert_includes response, truck.to_h
    end

  end

  test "GET /api/trucks omits closed trucks with open=true" do
    truck = food_trucks(:pizza)
    truck.update(open_sunday: false)
    
    Timecop.freeze("July 20, 1969 1:18 PM PST") do
      refute_predicate truck, :open?

      get api_trucks_url, params: { open: true }
      refute_includes response, truck.to_h
    end
  end

  test "GET /api/trucks filtering by minimum rating includes trucks above the minimum" do
    truck = food_trucks(:pizza)
    # TODO give the truck a 3-star rating

    get api_trucks_url, params: { min_rating: 3 }

    assert_includes response.map { |e| e[:id] }, truck.id
  end

  test "GET /api/trucks filtering by minimum rating excludes trucks below the minimum" do
    truck = food_trucks(:pizza)
    # TODO give the truck a 3-star rating

    get api_trucks_url, params: { min_rating: 4 }
  

    refute_includes response.map { |e| e[:id] }, truck.id
  end

  test "GET /api/trucks filters by tag" do
    truck = food_trucks(:pizza)

    get api_trucks_url, params: { tags: ["pizza"] }
    assert_includes response, truck.to_h
  end

  test "GET /api/trucks filters out trucks not tagged" do
    truck = food_trucks(:pizza)

    get api_trucks_url, params: { tags: ["vegan"] }
    refute_includes response, truck.to_h
  end

  test "GET /api/trucks filters trucks matching multiple tags" do
    truck = food_trucks(:pizza)

    get api_trucks_url, params: { tags: ["pizza", "wood-fired"] }
    assert_includes response, truck.to_h
  end

  test "GET /api/trucks filters out trucks matching only one tag" do
    truck = food_trucks(:pizza)
    
    get api_trucks_url, params: { tags: ["pizza", "burritos"] }
    refute_includes response, truck.to_h
  end


  def response
    @parsed_response ||= JSON.parse(@response.body, symbolize_names: true)
  end

end
