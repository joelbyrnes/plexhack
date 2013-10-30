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
    }.collect do |f| Torrent.new(f) end
  end

  def search_files(name)
    check_loaded
    found = @torrents.find_all do |t|
      t.files.any? { |f| f['name'].include? name }
    end
    found.collect do |f| Torrent.new(f) end
  end

  def find(id)
    Torrent.new(@tx.find(id))
  end

  #torrent = transmission_api.create("http://torrent.com/nice_pic.torrent")
  #transmission_api.destroy(id)

end

class Torrent

  attr_accessor :data
  attr_accessor :type
  attr_accessor :content_name

  #%w(name percentDone downloadDir).each do |meth|
  #  define_method(meth) { @data[meth.to_sym] }
  #end

  def initialize(data)
    @data = data

    tvmatch = name.match /(.*)\.[sS]([0-9]{1,2})[eE]([0-9]{1,2})/
    seasonmatch = name.match /(.*)\.[sS]([0-9]{1,2})/
    if tvmatch
      @type = "episode"
    elsif seasonmatch
      @type = "season"
      # todo multi-season
    else
      @type = "movie"
    end
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

  def media_files
    MediaFiles.new(files.collect do |f| f['name'] end)
  end

  def complete
    percentDone == 1.0
  end

  def isFinished
    @data['isFinished']
  end

end

class MediaFiles

  attr_accessor :files

  def initialize(files)
    @files = files
  end

  def size
    @files.size
  end

  def all_rars
    files.find_all do |f| f =~ /\.rar$/ end
  end

  def subs_rars
    all_rars.find_all do |f| f =~ /sub.*\.rar$|Sub.*\.rar$/ end
  end

  def content_rars
    all_rars - subs_rars
  end

  def non_rar_files
    @files - (@files.find_all do |f| f =~ /\.rar|.r[0-9]{2}$/ end)
  end

  def video_files
    files.find_all do |f| f =~ /\.mkv$|\.avi$|\.mpg$|\.mpeg$|\.mp4$/ end
  end

  def sample_videos
    video_files.find_all do |f| f =~ /sample/ end
  end

  def content_videos
    video_files - sample_videos
  end

  def file_paths(files, pathPrefix)
    files.collect do |f|
      (Pathname.new(pathPrefix) + f).to_s
    end
  end

end

def examine(t)
  puts "** torrent: #{t.name} (#{t.id})"
  #puts t.data
  #puts t.files[0]

  if t.complete
    puts "complete"
  else
    puts "not complete (#{t.percentDone * 100}%)"
  end

  media = t.media_files
  puts "#{media.size} files"
  media.files.each do |f|
    #puts Pathname.new(f).exist? "exists " : "does not exist "
    #if Pathname.new(f).exist? print "exists "
    #puts f
  end

  puts "subs rars: #{media.subs_rars}"

  puts "contains #{media.content_rars.count} content rars"
  puts media.content_rars

  puts "non-rar files #{media.non_rar_files}"

  puts "sample vids: #{media.sample_videos}"

  puts "contains #{media.content_videos.count} content videos: "
  puts media.content_videos

  if t.type == "episode"
    tvmatch = t.name.match /(.*)\.[sS]([0-9]{1,2})[eE]([0-9]{1,2})/
    puts "looks like TV show: " + tvmatch[1].gsub(/\./, ' ')
    puts "season " + Integer(tvmatch[2]).to_s
    puts "episode " + Integer(tvmatch[3]).to_s
  elsif t.type == "season"
    seasonmatch = t.name.match /(.*)\.[sS]([0-9]{1,2})/
    puts "looks like TV show season pack: " + seasonmatch[1].gsub(/\./, ' ')
    puts "season " + Integer(seasonmatch[2]).to_s
  elsif t.type == "movie"
    puts "looks like movie: #{t.name}"
  end

  puts "-- dry run"
  dest = Pathname.new(@extractDir) + t.name
  puts "mkdir -p #{dest}"
  if media.content_rars.count
    puts "extract #{media.content_rars} to #{dest}"
  end
  puts "copy #{media.non_rar_files} to #{dest}"

  #puts "files in downloaded?"

  # copy: everything except video .rar and .rNN and .sfv - maybe not samples either

  # has subs
  # is not rarred (or only subs rars), or has a single rar set, or multiple rar sets (tv season?)
  # is extracted to somewhere
  # get name - try to match up in plex, otherwise match on extracted filename?


end

#downloadDir = "/Users/joel/temp/tv"
#downloadDir = "/Volumes/completed/"
@downloadDir = "//mac-mini/completed/"
@extractDir = "//mac-mini/3tb/Downloaded/"

#url = "http://jj.empireofscience.org:9091/transmission/rpc"
url = "http://mac-mini.local:9091/transmission/rpc"
#url = "http://newt.local:9091/transmission/rpc",

torrents = Torrents.new(:url => url)

#puts torrents.search("Return of the King")

#puts search_files(torrents, "A.Good.Day.To.Die.Hard.2013.720p.HC.WEB-DL.x264.AC3-Riding High.mkv")

#torrents[29..30].each do |t|
#  examine(t)
#end

# mkv ep
#examine(torrents[30])
examine(torrents.find(34))
# rars ep
#examine(torrents[35])
examine(torrents.find(39))
# season
#examine(torrents.search("Modern.Family.S04")[0])
# movie
#examine(torrents.search("Pain.and.Gain")[0])
examine(torrents.find(156))

# find movies with subs
#torrents.search_files("subs").each do |t|
#  examine(t)
#end

