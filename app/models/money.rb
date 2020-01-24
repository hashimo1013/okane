class Money < ActiveRecord::Base
  mount_uploader :image, ImageUploader
  belongs_to :user
  validates :expenses, presence: true
end