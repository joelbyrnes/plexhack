class Video < ActiveRecord::Base
  belongs_to :server
  attr_accessible :key, :media_type, :section, :title
end
