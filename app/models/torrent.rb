class Torrent

  attr_accessor :data, :type, :content_name

  # non-active record model needs these to work
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  def persisted?
    false
  end

  # TODO implement find(id) ie merge Torrents, and put transmission URL in a config file or something
  # allows use of /torrents/1 etc

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

  def complete?
    percentDone == 1.0
  end

  def isFinished?
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