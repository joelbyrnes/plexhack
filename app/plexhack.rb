require 'plex-ruby'

CONFIG = {:host => 'newt.local', :port => 32400}
#CONFIG = {:host => 'jj.empireofscience.org', :port => 11295}

# http://jj.empireofscience.org:11295/web/index.html

puts 'connecting'
server = Plex::Server.new(CONFIG[:host], CONFIG[:port])
puts "connected to #{server.url}"

sections = server.library.sections
sections.each { |s| puts s }
section = sections[1]                               # Pick the section you want I.E. TV, Movies, Home Videos
    shows = section.all                                 # Returns a list of shows/movies
st = shows.detect { |s| s.title =~ /Star/ }  # Pick a great show
season = st.last_season                            # Pick the last season
episode = season.episode(5)                         # The fifth episode in the season
#puts "#{episode.title} - #{episode.summary}"        # Looks good

# delegates to Video object
puts episode.genres

media = episode.media

media.parts.each do |p|
  puts p.file
  puts p.size
end

# MediaContainer/Video/Media/Part.file

#client.play_media(episode)                          # Play it!

