class VideoNotesController < ApplicationController
  # GET /video_notes
  # GET /video_notes.json
  def index
    @video_notes = VideoNote.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @video_notes }
    end
  end

  # GET /video_notes/1
  # GET /video_notes/1.json
  def show
    @video_note = VideoNote.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @video_note }
    end
  end

  # GET /video_notes/new
  # GET /video_notes/new.json
  def new
    @video_note = VideoNote.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @video_note }
    end
  end

  # GET /video_notes/1/edit
  def edit
    @video_note = VideoNote.find(params[:id])
  end

  # POST /video_notes
  # POST /video_notes.json
  def create
    @video_note = VideoNote.new(params[:video_note])

    respond_to do |format|
      if @video_note.save
        format.html { redirect_to @video_note, notice: 'Video note was successfully created.' }
        format.json { render json: @video_note, status: :created, location: @video_note }
      else
        format.html { render action: "new" }
        format.json { render json: @video_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /video_notes/1
  # PUT /video_notes/1.json
  def update
    @video_note = VideoNote.find(params[:id])

    respond_to do |format|
      if @video_note.update_attributes(params[:video_note])
        format.html { redirect_to @video_note, notice: 'Video note was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @video_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /video_notes/1
  # DELETE /video_notes/1.json
  def destroy
    @video_note = VideoNote.find(params[:id])
    @video_note.destroy

    respond_to do |format|
      format.html { redirect_to video_notes_url }
      format.json { head :no_content }
    end
  end
end
