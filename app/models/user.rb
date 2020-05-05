class User < ApplicationRecord
  has_one :api_key
  before_create :build_api_key
  #has_many :ratings, dependent: :destroy

  private

  def build_api_key
    ApiKey.new(user: self)
  end
end
