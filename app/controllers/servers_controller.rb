class ServersController < ApplicationController
  # GET /servers
  # GET /servers.json
  def index
    @servers = Server.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @servers }
    end
  end

  # GET /servers/1
  # GET /servers/1.json
  def show
    @server = Server.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @server }
    end
  end

  # GET /servers/new
  # GET /servers/new.json
  def new
    @server = Server.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @server }
    end
  end

  # GET /servers/1/edit
  def edit
    @server = Server.find(params[:id])
  end

  # GET /servers/1/refresh
  def refresh
    @server = Server.find(params[:id])

    refresh_media(@server)
  end

  def refresh_media(server)

    require 'nokogiri'
    require 'net/http'
    require 'active_support/core_ext'

    # TODO iterate over sections and separate movies and tv shows
    section = 4

    #TODO remove missing movies

    xml = Net::HTTP.get(server.host, "/library/sections/#{section}/all", server.port)

    doc = Nokogiri::HTML.parse(xml)

    found_videos = doc.xpath("//mediacontainer/video")

    @videos = []

    found_videos.each do |i|
      puts i[:key], i[:title]
      video = Video.find_by_key(i[:key])

      if video
        video.update_attributes(:key => i[:key], :title => i[:title], :media_type => i[:type], :section => section)
      else
        video = Video.new(:key => i[:key], :title => i[:title], :media_type => i[:type], :section => section)
        video.server = server
      end

      video.save

      @videos << video
    end

  end

  # POST /servers
  # POST /servers.json
  def create
    @server = Server.new(params[:server])

    respond_to do |format|
      if @server.save
        format.html { redirect_to @server, notice: 'Server was successfully created.' }
        format.json { render json: @server, status: :created, location: @server }
      else
        format.html { render action: "new" }
        format.json { render json: @server.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /servers/1
  # PUT /servers/1.json
  def update
    @server = Server.find(params[:id])

    respond_to do |format|
      if @server.update_attributes(params[:server])
        format.html { redirect_to @server, notice: 'Server was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @server.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /servers/1
  # DELETE /servers/1.json
  def destroy
    @server = Server.find(params[:id])
    @server.destroy

    respond_to do |format|
      format.html { redirect_to servers_url }
      format.json { head :no_content }
    end
  end

  # GET /videos
  # GET /videos.json
  def videos
    @videos = Video.find_all_by_server_id(params[:id])
    print @videos.size

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @videos }
    end
  end
end
