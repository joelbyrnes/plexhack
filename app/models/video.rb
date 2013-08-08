class Video < ActiveRecord::Base
  belongs_to :server
  attr_accessible :key, :media_type, :section, :title

  def self.search(conditions)
    find(:all, conditions)
  end
end
