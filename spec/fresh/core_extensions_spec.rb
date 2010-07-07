require 'spec_helper'

class MyObject
  include Fresh::CoreExtensions
end

describe "CoreExtensions" do
  before do
    @o = MyObject.new
  end

  describe "#require_keys" do
    it "should raise exception if missing required key" do
      lambda {
        @o.require_keys({:name => 'foo'}, :value)
      }.should raise_error(ArgumentError, "Missing required key(s): value")
    end

    it "should not raise exception if not missing required key" do
      lambda {
        @o.require_keys({:name => 'foo', :value => 'bar'}, :value)
      }.should_not raise_error
    end

    it "should raise exception if missing required keys" do
      lambda {
        @o.require_keys({}, :name, :value)
      }.should raise_error(ArgumentError, "Missing required key(s): name, value")
    end

    it "should not raise exception if not missing required keys" do
      lambda {
        @o.require_keys({:name => 'foo', :value => 'bar'}, :name, :value)
      }.should_not raise_error
    end
  end

  describe "#required_values" do
    it "should return values of required keys" do
      @o.expects(:require_keys).with({:name => 'foo', :value => 'bar'}, :name, :value)
      foo, bar = @o.required_values({:name => 'foo', :value => 'bar'}, :name, :value)
      foo.should == 'foo'
      bar.should == 'bar'
    end

    it "should return value of required key" do
      @o.expects(:require_keys).with({:name => 'foo', :value => 'bar'}, :name)
      foo = @o.required_values({:name => 'foo', :value => 'bar'}, :name)
      foo.should == 'foo'
    end
  end
end

describe "CoreExtensions::Hash" do
  describe "difference" do
    before do
      @a = {:a1 => 0, :a2 => 0}
      @b = {:b1 => 0, :b2 => 0}
      @c = {:a1 => 0, :b1 => 0}
    end

    it "should not get difference" do
      (@a - @b).should == @a
      (@b - @a).should == @b
    end

    it "should get keys in a but not in c" do
      (@a - @c).should == {:a2 => 0}
    end

    it "should get keys in c but not in a" do
      (@c - @a).should == {:b1 => 0}
    end
  end

  describe "modified" do
    before do
      @a = {:one => 0, :two => 0}
      @b = {:one => 0, :two => 0}
      @c = {:one => 1}
    end

    it "should not get modified" do
      (@a =~ @b).should == {}
      (@b =~ @a).should == {}
    end

    it "should get modifications for a with c" do
      (@a =~ @c).should == {:one => {0 => 1}}
    end

    it "should get modifications for c with a" do
      (@c =~ @a).should == {:one => {1 => 0}}
    end
  end
end