require 'spec_helper'

describe ParrotTn::ParserYml do
  context "When a yaml file needs to be translated" do
    it "should translate" do
      parser = subject.class.new :google => true

      # dont convert to page code
      parser.instance_variable_get("@guess").instance_variable_get("@tr").stub(:user_agent).and_return("foo")

      parser.parrotize_yaml "spec/lib/samples/translate_it.yml", :fr, :save_to => "./spec/lib/samples/tmp/result_spec.yml"

      parser.instance_variable_get("@allyaml").should == { :fr=>{"account_type"=>{"current"=>"Courant", "cash_in_hand"=>"Encaisse", "other"=>"Autre"}, "misc"=>["Plan", "Voiture"], "zz"=>12}}
    end

    it "should raise an error because the file cannot be written" do
      parser = subject.class.new :google => true

      # dont convert to page code
      parser.instance_variable_get("@guess").instance_variable_get("@tr").stub(:user_agent).and_return("foo")

      lambda { parser.parrotize_yaml "spec/lib/samples/translate_it.yml", :fr, :save_to => "/xx/yy/blah.yml" }.should raise_error
    end
  end
end
