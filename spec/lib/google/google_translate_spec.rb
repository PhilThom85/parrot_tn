require 'spec_helper'

describe Google::Translate do
  context "When bad parameters are given" do
    it "should raise exception on text parameter" do
      lambda { subject.translate :text => "", :from => :en, :to => :fr }.should raise_error( ArgumentError )
    end
    it "should raise exception on :from lang" do
      lambda { subject.translate :text => "Hello", :from => :xx, :to => :fr }.should raise_error( ArgumentError )
    end
    it "should raise exception on :to lang" do
      lambda { subject.translate :text => "Hello", :from => :en, :to => :xx }.should raise_error( ArgumentError )
    end
  end

  context "When user_agent is set" do
    class FakeSearchResult
      def inner_text
        "o\u00fb allez-vous?"
      end
    end
    class FakePostResult
      def search(arg)
        FakeSearchResult.new
      end
    end

    describe "to false" do
      it "should not convert text" do
        sample = "o\u00fb allez-vous?"
        tr = subject.class.new do |agent|
          agent.user_agent = false
          agent.stub(:post).and_return(FakePostResult.new)
        end

        tr.translate(:text => 'where are you going?', :from => :en, :to => :fr).should == sample
      end
    end
  end
end
