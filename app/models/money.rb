class Money < ActiveRecord::Base
  mount_uploader :image, ImageUploader
  belongs_to :user
  belongs_to :tag
  validates :expenses, presence: true
end