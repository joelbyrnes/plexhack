require 'test_helper'

class VideoNotesControllerTest < ActionController::TestCase
  setup do
    @video_note = video_notes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:video_notes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create video_note" do
    assert_difference('VideoNote.count') do
      post :create, video_note: { comment: @video_note.comment, rating: @video_note.rating }
    end

    assert_redirected_to video_note_path(assigns(:video_note))
  end

  test "should show video_note" do
    get :show, id: @video_note
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @video_note
    assert_response :success
  end

  test "should update video_note" do
    put :update, id: @video_note, video_note: { comment: @video_note.comment, rating: @video_note.rating }
    assert_redirected_to video_note_path(assigns(:video_note))
  end

  test "should destroy video_note" do
    assert_difference('VideoNote.count', -1) do
      delete :destroy, id: @video_note
    end

    assert_redirected_to video_notes_path
  end
end
