require 'plex-ruby'
require 'transmission_api'

class Torrents
  attr_accessor :tx
  attr_accessor :torrents

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

  def initialize(opts)
    # username and password optional
    opts[:fields] = TORRENT_FIELDS
    @tx = TransmissionApi.new(opts)
  end

  def load
    @torrents = @tx.all.collect do |t|
      Torrent.new(t)
    end
  end

  def check_loaded
    if !@torrents
      load
    end
  end

  def [](y)
    check_loaded
    @torrents[y]
  end

  def all
    check_loaded
    @torrents
  end

  def search(name)
    check_loaded
    @torrents.find_all { |t|
      t.name.include? name
    }
  end

  def search_files(name)
    check_loaded
    @torrents.find_all do |t|
      t.files.any? { |f| f['name'].include? name }
    end
  end

  def find(id)
    Torrent.new(@tx.find(id))
  end

  #torrent = transmission_api.create("http://torrent.com/nice_pic.torrent")
  #transmission_api.destroy(id)

end

class Torrent

  attr_accessor :data

  #%w(name percentDone downloadDir).each do |meth|
  #  define_method(meth) { @data[meth.to_sym] }
  #end

  def initialize(data)
    @data = data
  end

  def id
    @data['id']
  end

  def name
    @data['name']
  end

  def files
    @data['files']
  end

  def percentDone
    @data['percentDone']
  end

  def downloadDir
    @data['downloadDir']
  end

  def file_paths(pathPrefix = "")
    fs = files.collect do |f| f['name'] end
    fs.collect do |f|
      path = Pathname.new(downloadDir) + f
      #path = Pathname.new(pathPrefix) + f
      path.to_s
    end
  end

  def complete
    percentDone == 1.0
  end

  def all_rars
    file_paths.find_all do |f| f =~ /\.rar$/ end
  end

  def subs_rars
    all_rars.find_all do |f| f =~ /sub.*\.rar$|Sub.*\.rar$/ end
  end

end

class DownloadedFiles

end


#downloadDir = "/Users/joel/temp/tv"
#downloadDir = "/Volumes/completed/"
@downloadDir = "//mac-mini/completed/"
extractDir = "//mac-mini/3tb/Downloaded/"

#url = "http://jj.empireofscience.org:9091/transmission/rpc"
url = "http://mac-mini.local:9091/transmission/rpc"
#url = "http://newt.local:9091/transmission/rpc",

torrents = Torrents.new(:url => url)

def examine(t)
  puts "** torrent: #{t.name} (#{t.id})"
  #puts t.data
  #puts t.files[0]

  if t.complete
    puts "complete"
  else
    puts "not complete (#{t.percentDone * 100}%)"
  end

  files = t.file_paths
  files.each do |f|
    #puts Pathname.new(f).exist? "exists " : "does not exist "
    #if Pathname.new(f).exist? print "exists "
    #puts f
  end


  # movie(s)/tv show(s)/unknown - tv title has sXXeYY, movies are usually 2gb+
  tvmatch = t.name.match /(.*)\.[sS]([0-9]{1,2})[eE]([0-9]{1,2})/
  seasonmatch = t.name.match /(.*)\.[sS]([0-9]{1,2})/
  if tvmatch
    puts "looks like TV show: " + tvmatch[1].gsub(/\./, ' ')
    puts "season " + Integer(tvmatch[2]).to_s
    puts "episode " + Integer(tvmatch[3]).to_s
  elsif seasonmatch
     puts "looks like TV show season pack: " + seasonmatch[1].gsub(/\./, ' ')
     puts "season " + Integer(seasonmatch[2]).to_s
  else
    puts "looks like movie: #{t.name}"
  end

  rar_files = t.all_rars
  if rar_files.count
    puts "contains #{rar_files.count} rars"
    subs_files = t.subs_rars
    if subs_files.count
      puts "subs rars: #{subs_files}"
    end
    real_rars = rar_files - subs_files
    puts "contains #{real_rars.count} real rars"
    puts real_rars
  else puts "does not contain rars"
  end

  video_files = files.find_all do |f| f =~ /\.mkv$|\.avi$|\.mpg$|\.mpeg$|\.mp4$/ end
  if video_files.count do
    sample_videos = video_files.find_all do |f| f =~ /sample/ end
    if sample_videos.count
      puts "sample vids: #{sample_videos}"
    end
    puts "without samples: #{video_files - sample_videos}"
    real_vid_files = video_files - sample_videos
    puts "contains #{real_vid_files.count} video files: "
    puts real_vid_files

    #puts "files in downloaded?"
  end

  else puts "does not contain video file" end


  # copy: everything except video .rar and .rNN and .sfv - maybe not samples either

  # has subs
  # is not rarred (or only subs rars), or has a single rar set, or multiple rar sets (tv season?)
  # is extracted to somewhere
  # get name - try to match up in plex, otherwise match on extracted filename?


end

#puts torrents.search("Return of the King")

#puts search_files(torrents, "A.Good.Day.To.Die.Hard.2013.720p.HC.WEB-DL.x264.AC3-Riding High.mkv")

#torrents[29..30].each do |t|
#  examine(t)
#end

# mkv ep
#examine(torrents[30])
# rars ep
#examine(torrents[35])
# season
#examine(torrents.search("Modern.Family.S04")[0])
# movie
#examine(torrents.search("Pain.and.Gain")[0])
examine(torrents.find(156))

# find movies with subs
#torrents.search_files("subs").each do |t|
#  examine(t)
#end

