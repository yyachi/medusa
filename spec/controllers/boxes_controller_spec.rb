require 'spec_helper'
include ActionDispatch::TestProcess

describe BoxesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET index" do
    let(:box_1) { FactoryGirl.create(:box, name: "hoge") }
    let(:box_2) { FactoryGirl.create(:box, name: "box_2") }
    let(:box_3) { FactoryGirl.create(:box, name: "box_3") }
    before do
      box_1;box_2;box_3
      get :index
    end
    it { expect(assigns(:boxes).count).to eq 3 }
  end

  describe "POST upload" do
    let(:obj){FactoryGirl.create(:box) }
    let(:media) {fixture_file_upload("/files/test_image.jpg",'image/jpeg') }
    it { expect {post :upload, id: obj.id  ,media: media}.to change(AttachmentFile, :count).by(1) }
    context "" do
      before{post :upload, id: obj.id  ,media: media}
      it{expect(assigns(:box).attachment_files.last.data_file_name).to eq "test_image.jpg"}
    end
  end

end