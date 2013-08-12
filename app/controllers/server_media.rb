require 'nokogiri'
require 'net/http'
require 'active_support/core_ext'

class ServerMedia

  def initialize(server)
    @server = server
  end

  def sections
    xml = Net::HTTP.get(@server.host, "/library/sections", @server.port)
    doc = Nokogiri::HTML.parse(xml)
    doc.xpath("//directory[@type='movie']")
    #doc.xpath("//directory[@type='movie']").map do |s|
    #
    #  section = {}
    #  section = {:key => s[:key]}
    #  #section.key = ''
    #  #section.type = ''
    #  #section.title = ''
    #
    #  section
    #end
  end

  def refresh_media()
    found_movie_sections = sections

    # TODO do tv shows

    videos = found_movie_sections.map do |s|
#      print s[:key], s[:type]
      refreshed = self.refresh_videos(s[:key])
      # the splat * adds the elements of the array, instead of the array, to videos.
      #videos.push(*refreshed)
      #videos.concat(refreshed)
    end

    videos.flatten()
  end

  def refresh_videos(section_key)
    puts "refreshing videos from #{@server.name} section #{section_key}"

    xml = Net::HTTP.get(@server.host, "/library/sections/#{section_key}/all", @server.port)
    doc = Nokogiri::HTML.parse(xml)

    found_videos = doc.xpath("//mediacontainer/video")

    videos = []
    @existing = 0
    @added = 0
    @deleted = 0

    found_videos.each do |i|
      #puts i[:key], i[:title]
      matches = Video.search(:conditions => ['server_id = ? AND key = ?', @server.id, i[:key]])
      throw Exception("too many movie matches") if matches.size > 1
      video = matches[0]

      if video
        puts "existing video: #{video.title}"
        @existing += 1
        video.update_attributes(:key => i[:key], :title => i[:title], :media_type => i[:type], :section => section_key)
      else
        puts "new video: #{i[:title]}"
        @added += 1
        video = Video.new(:key => i[:key], :title => i[:title], :media_type => i[:type], :section => section_key)
        video.server = @server
      end

      # TODO remove missing movies

      video.save

      videos << video
    end

    puts "added #{@added}, updated #{@existing} videos."

    videos
  end

end