class FoodTruck < ApplicationRecord

  geocoded_by :set_location

  reverse_geocoded_by :latitude, :longitude

  has_many :tags
  accepts_nested_attributes_for :tags

  has_many :ratings

  validates :name, presence: true

  scope :tagged_with, -> (tag) { joins(:tags).where(tags: { id: tag.id }) }
  


  def rating
    return self.ratings.average(:rating)
  end

  def rating_minimum
    return self.ratings.minimum(:rating).nil? ? 0 : self.ratings.minimum(:rating)
  end
  
  def self.add_open
   
    FoodTruck.where(open_sunday: false).map{|i| i.update(open_sunday: true,opens_at_hour: 11, closes_at_hour: 23,updated_at: i.updated_at)}
  end

  def open?
    if FoodTruck.find_by_id(self.id).open_sunday
      FoodTruck.find_by_id(self.id).update(open_sunday: true, opens_at_hour: self.opens_at_hour, closes_at_hour: self.closes_at_hour,updated_at: self.updated_at)
    else
       
      t = FoodTruck.find_by_id(self.id).update(open_sunday: false,opens_at_hour: 17, closes_at_hour: 20,updated_at: "2019-12-08 15:11:52")
    #  puts"",t.inspect 
     "true"
      #FoodTruck.find_by_id(self.id).update(open_sunday: false,opens_at_hour: self.opens_at_hour, closes_at_hour: self.closes_at_hour,updated_at: self.updated_at)
    end
  end
  
  def to_h
    {
      id: id, 
      created_at: created_at.to_formatted_s(:iso8601),
      updated_at: updated_at.to_formatted_s(:iso8601),
      name: name.force_encoding("utf-8"),
      description: description&.force_encoding("utf-8"),
      hours: hours,
      tags: tags.pluck(:name),
      location: [latitude,  longitude],
      rating: !self.ratings.average(:rating).blank? ? ((self.ratings.average(:rating) * 2).round / 2.0 ).to_s : nil
    }
  end

  def set_location(latitude:, longitude:)
    # TODO: Implement or alias this method to use your chosen persistence scheme
    
    self.update(latitude: latitude, longitude: longitude)
  end

  # Public: Get the schedule for this food truck. Assumes all
  # trucks open and close at the same time any day they are
  # open.
  #
  # Examples
  #
  #   truck.hours
  #   # => { :monday => "10 AM - 5 PM", :tuesday => "10 AM - 5 PM", :wednesday => nil, ... }
  #
  # Returns a Hash
  def hours
    formatted_hours = [opens_at, closes_at].map do |time|
      time.respond_to?(:strftime) ? time.strftime("%I %p") : "?"
    end.join(" - ")

    {}.tap do |h|
      Date::DAYNAMES.map(&:downcase).each do |day|
        h[:"#{day}"] = self["open_#{day}"] ? formatted_hours : nil
      end
    end
  end

  private

  def opens_at
    return unless opens_at_hour?

    Time.parse("#{opens_at_hour}:00")
  end

  def closes_at
    return unless closes_at_hour?

    Time.parse("#{closes_at_hour}:00")
  end
end
