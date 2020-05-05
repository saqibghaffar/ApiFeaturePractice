# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#

trucks = YAML::load_file(File.join(__dir__, "seeds", "trucks.yml"))

open_day_variants = []
open_day_variants << Date::DAYNAMES
open_day_variants << Date::DAYNAMES - %w(Sunday)
open_day_variants << Date::DAYNAMES - %w(Sunday Monday)
open_day_variants << Date::DAYNAMES - %w(Sunday Monday Tuesday)
open_day_variants << Date::DAYNAMES - %w(Saturday Sunday)
open_day_variants << Date::DAYNAMES - %w(Monday Tuesday)

users_before_count = User.count
trucks_before_count = FoodTruck.count

User.where(login: "hungry_harry").first_or_create
User.where(login: "ravenous_rachel").first_or_create

trucks.each do |truck_data|
  next if FoodTruck.exists?(name: truck_data["name"])

  FoodTruck.new(truck_data.except("tags")).tap do |truck|
    truck.opens_at_hour = (10..17).to_a.sample
    truck.closes_at_hour = (18..24).to_a.sample

    open_day_variants.sample.each do |dayname|
      truck.write_attribute("open_#{dayname.downcase}", true)
    end

    truck.tags_attributes = truck_data["tags"].map do |tag_name|
      { name: tag_name }
    end
  end.save!
end

users_created = User.count - users_before_count
trucks_created = FoodTruck.count - trucks_before_count

puts "\nSeeded #{users_created} user#{'s' unless users_created == 1}. #{"💁  " * users_created}"
puts "Seeded #{trucks_created} food truck#{'s' unless trucks_created == 1}. #{"🚚  " * trucks_created}"
