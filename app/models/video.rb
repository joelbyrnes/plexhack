class Video < ActiveRecord::Base
  belongs_to :server
  attr_accessible :key, :media_type, :section, :title

  # this is bad and you should feel bad
  def self.search(conditions)
    find(:all, conditions)
  end
end
