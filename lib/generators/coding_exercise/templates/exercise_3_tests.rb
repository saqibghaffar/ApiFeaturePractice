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
