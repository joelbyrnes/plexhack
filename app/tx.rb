require 'plex-ruby'
require 'transmission_api'

transmission_api = TransmissionApi.new(
        #:username => "username",
        #:password => "password",
        #:url      => "http://jj.empireofscience.org:9091/transmission/rpc"
        #:url      => "http://mac-mini.local:9091/transmission/rpc"
        :url      => "http://newt.local:9091/transmission/rpc"
)

torrents = transmission_api.all
#torrent = transmission_api.find(id)
#torrent = transmission_api.create("http://torrent.com/nice_pic.torrent")
#transmission_api.destroy(id)

#puts torrents[0]

def search(torrents, name)
  torrents.find_all { |t|
    t['name'].include? name
  }
end

def search_files(torrents, name)
  torrents.find_all do |t|
    t['files'].any? { |f| f['name'].include? name }
  end
end

puts search(torrents, "Return of the King")

puts search_files(torrents, "A.Good.Day.To.Die.Hard.2013.720p.HC.WEB-DL.x264.AC3-Riding High.mkv")

torrents.each do |t|
  puts "** torrent: #{t['name']}"

  puts "files: "
  files = t['files'].collect do |f| f['name'] end
  #puts
  files.each do |f|
    #puts File.new(f)
  end

  puts "not complete (#{t['percentDone'] * 100}%)" if t['percentDone'] < 1.0

  # movie(s)/tv show(s)/unknown - tv title has sXXeYY, movies are usually 2gb+
  match = t['name'].match /(.*)\.[sS]([0-9]{1,2})[eE]([0-9]{1,2})/
  if match
    puts "looks like TV show: " + match[1].sub(/\./, ' ')
    puts "season " + Integer(match[2]).to_s
    puts "episode " + Integer(match[3]).to_s
  else
    puts "looks like movie: #{t['name']}"
  end


  puts "contains rars" if files.any? do |f| f.include? '.rar' end

  puts "contains video file" if files.any? do |f| f =~ /\.mkv$|\.avi$|\.mpg$|\.mpeg$|\.mp4$/ end


  # has subs
  # is not rarred (or only subs rars), or has a single rar set, or multiple rar sets (tv season?)
  # is extracted to somewhere
  # get name - try to match up in plex, otherwise match on extracted filename?

end
