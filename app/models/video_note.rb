class VideoNote < ActiveRecord::Base
  belongs_to :video
  belongs_to :user
  attr_accessible :comment, :rating
end
