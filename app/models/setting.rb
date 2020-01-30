class Setting < ApplicationRecord
  validates :key, :value, presence: true
  validates :key, uniqueness: true

  def self.[](key)
    Rails.cache.fetch("Setting/#{key}", expires: 24.hours) do
      find_by(key: key)&.value
    end
  end
end
