require 'plex-ruby'
require 'transmission_api'

class TorrentsController < ApplicationController

  #@url = "http://jj.empireofscience.org:9091/transmission/rpc"
  #@url = "http://mac-mini.local:9091/transmission/rpc"
  @url = "http://newt.local:9091/transmission/rpc"

  # GET /torrents
  # GET /torrents.json
  def index
    @torrents = Torrents.new(:url => "http://newt.local:9091/transmission/rpc").load

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @torrents }
    end
  end

  # GET /torrents/1
  # GET /torrents/1.json
  def show
    @torrent = Torrents.new(:url => "http://newt.local:9091/transmission/rpc").find(Integer(params[:id]))

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @torrent }
    end
  end

  # DELETE /torrents/1
  # DELETE /torrents/1.json
  def destroy
    @torrent = Torrents.new(:url => "http://newt.local:9091/transmission/rpc").find(Integer(params[:id]))
    @torrent.destroy

    respond_to do |format|
      format.html { redirect_to torrents_url }
      format.json { head :no_content }
    end
  end
end



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


