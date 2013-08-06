class Server < ActiveRecord::Base
  attr_accessible :address, :host, :name, :port
  has_many :videos
end
