class Rating < ApplicationRecord
	#belongs_to :user , optional: true
	belongs_to :food_truck  , optional: true
	#validates :comment, presence: true,
	#					length: { minimum: 5}
end
