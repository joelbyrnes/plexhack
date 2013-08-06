require 'nokogiri'
require 'net/http'
require 'active_support/core_ext'

server = "newt.local"
section = 4

xml = Net::HTTP.get(server, "/library/sections/#{section}/all", 32400)
#result = Net::HTTP.get(URI.parse('http://www.site.com/about.html'))

doc = Nokogiri::HTML.parse(xml)

videos = doc.xpath("//mediacontainer/video")
puts videos.size

videos.each { |i|
  puts i[:key], i[:title]
  #Video.new(:key => i[:key], :title => i[:title], :type => i[:type], :section => section, :server => server)
}

#results = doc.xpath("//div[contains(@class, 'resultBody') and @class!='resultBodyWrapper']")
#htmldata = results.map do |result|
#  parse_property result
#end

