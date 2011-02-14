require File.dirname(__FILE__) + '/../spec_helper'

describe KeywordsController do

  before(:each) do
    @keyword = Factory.create(:keyword)
  end

  it "should get index" do
    get :index
    response.should be_success
    assigns(:keywords).should_not be_nil
  end

  it "should show keyword" do
    get :show, :id => @keyword.id
    response.should be_success
  end

  context "requiring login" do
    before(:each) do
      login_as :activated_user
    end

    it "should get new" do
      get :new
      response.should be_success
    end

    it "should create keyword" do
      count = Keyword.count
      post :create, :keyword => {:name => 'keyword'}
      Keyword.count.should == count + 1
      response.should redirect_to(keyword_path(assigns(:keyword)))
    end

    it "should get edit" do
      get :edit, :id => @keyword.id
      response.should be_success
    end

    it "should update keyword" do
      put :update, :id => @keyword.id, :keyword => {:name => 'new_name'}
      response.should redirect_to(keyword_url(@keyword))
      @keyword.reload.name.should == 'new_name'
    end

    it "should destroy keyword" do
      count = Keyword.count
      delete :destroy, :id => @keyword.id
      Keyword.count.should == count - 1
      response.should redirect_to(keywords_url())
      Keyword.find_by_id(@keyword.id).should be_nil
    end
  end

end