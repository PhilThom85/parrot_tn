require 'spec_helper'

describe ParrotTn::Guess do
  let(:hash_test)  { { :fr_en => "foo", :en_fr => [ "file1", "file2"] } }

  context "for each options supplied" do
    describe "google option" do
      it "should be false by default" do
        subject.google?.should be_false
      end
      it "should set the google option to true" do
        guess = subject.class.new :google => true

        guess.google?.should be_true
      end
      it "should set the google option to false" do
        guess = subject.class.new :google => false

        guess.google?.should be_false
      end
    end

    describe "dicts option" do
      it "should be empty when not supplied" do
        subject.dicts.should be_empty
      end

      it "should initalize the dicts file" do
        guess = subject.class.new :dicts => hash_test

        guess.dicts.should == hash_test
      end
    end

    describe "strict option" do
      it "should not return NT - when no translation if set to true" do
        @guess = subject.class.new  :google => false, :strict => true

        @guess.translation("harrowing", :en, :fr).should_not == "NT - harrowing"
        @guess.translation("harrowing", :en, :fr).should == "harrowing"
      end
    end
  end

  context "when load options is supplied" do
    it "should not initialize with the config file" do
      guess = subject.class.new :load => "blah"

      guess.google?.should be_false
      guess.dicts.should be_empty
    end
    it "should initialize with the config file" do
      guess = subject.class.new :load => "./spec/lib/samples/fake_config.yml"

      guess.google?.should be_true
      guess.dicts.should == hash_test
    end

    describe "and dictionnaries in different languages are supplied" do
      context "When translation exists in dictionnaries" do
        before :each do
          @guess = subject.class.new  :load => "./spec/lib/samples/real_config.yml"
        end

        it "should have translation from english to french" do
          @guess.translation("House", :en, :fr).should == "Maison"
        end
        it "should have translation from french to english" do
          @guess.translation("Chien", :fr, :en).should == "Dog"
        end
        it "should have special translation from en to fr" do
          @guess.translation("Tip", :en, :fr).should == "Tuyau"
        end
      end

      context "When there is no available translation" do
        before :each do
          @guess = subject.class.new  :load => "./spec/lib/samples/real_config.yml"
        end
        it "should not call google and return NT - msg" do
          @guess.reset_options_with :google => false

          @guess.translation("harrowing", :en, :fr).should == "NT - harrowing"
        end
        it "should call google and return translated msg" do
          @guess.translation("harrowing", :en, :fr).should == "hersage"
        end

        it "should fail to translate with google and fallback with NT -" do
          @guess.translation("thisntacorectword", :en, :fr).should == "NT - thisntacorectword"
        end
      end

      describe "when object is defined" do
        it "should be possible to change options" do
          guess = subject.class.new  :load => "./spec/lib/samples/real_config.yml"

          guess.reset_options_with :google => false, :strict => true, :user_agent => false

          guess.google?.should be_false
          guess.instance_variable_get("@strict").should be_true
          guess.instance_variable_get("@agent").should be_false
        end
      end
    end
  end

  describe :get_defined_proxy do
    around :each do |test|
      ENV.select do |k,v| 
        if k =~ /http_proxy/i
          @sv = v
          ENV.delete(k)
        end
      end
      ENV.select do|k,v| 
        if k =~ /all_proxy/i
          @svall = v
          ENV.delete(k)
        end
      end
      ENV["all_proxy"]="http://www.google.com"

      test.run

      ENV["http_proxy"] = @sv unless @sv.nil?
      ENV["all_proxy"] = @svall unless @svall.nil?
    end

    it "should fallback to all_proxy env" do
      URI.should_receive(:parse).with("http://www.google.com")
      subject.send(:get_defined_proxy)
    end
  end
end

