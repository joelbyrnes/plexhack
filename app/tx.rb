require 'plex-ruby'
require 'transmission_api'

#downloadDir = "/Users/joel/temp/tv"
downloadDir = "/Volumes/completed"
extractDir = "/Volumes/3TB/Downloaded"

# see https://trac.transmissionbt.com/browser/branches/1.7x/doc/rpc-spec.txt - 3.3.  Torrent Accessors
TORRENT_FIELDS = [
    "id",
    "name",
    "totalSize",
    "addedDate",
    "isFinished",
    "rateDownload",
    "rateUpload",
    "percentDone",
    "files",
    'downloadDir'
]

transmission_api = TransmissionApi.new(
    #:username => "username",
    #:password => "password",
    #:url      => "http://jj.empireofscience.org:9091/transmission/rpc",
    :url      => "http://mac-mini.local:9091/transmission/rpc",
    #:url      => "http://newt.local:9091/transmission/rpc",
    :fields   => TORRENT_FIELDS
)

torrents = transmission_api.all
#torrent = transmission_api.find(id)
#torrent = transmission_api.create("http://torrent.com/nice_pic.torrent")
#transmission_api.destroy(id)

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

#puts search(torrents, "Return of the King")

#puts search_files(torrents, "A.Good.Day.To.Die.Hard.2013.720p.HC.WEB-DL.x264.AC3-Riding High.mkv")

def file_paths(torrent)
  files = torrent['files'].collect do |f| f['name'] end
  files.collect do |f|
    #path = Pathname.new(torrent['downloadDir']) + f
    path = Pathname.new("/Volumes/completed") + f
    path.to_s
  end
end

def examine(t)
  puts "** torrent: #{t['name']}"
  #puts t

  puts "files: "
  files = file_paths(t)
  files.each do |f|
    #puts Pathname.new(f).exist? "exists " : "does not exist "
    #if Pathname.new(f).exist? print "exists "
    puts f
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


  if (files.any? do |f| f.include? '.rar' end)
    puts "contains rars"
  else puts "does not contain rars"
  end

  video_files = files.find_all do |f| f =~ /\.mkv$|\.avi$|\.mpg$|\.mpeg$|\.mp4$/ end
  if video_files.count do
    puts "contains #{video_files.count} video files"
    puts video_files
  end
  else puts "does not contain video file" end


  # has subs
  # is not rarred (or only subs rars), or has a single rar set, or multiple rar sets (tv season?)
  # is extracted to somewhere
  # get name - try to match up in plex, otherwise match on extracted filename?


end


torrents[29..30].each do |t|
  examine(t)
end

