require 'spec_helper'

describe Fresh::Wrench do
  before do
    Fresh::Syncer.stubs(:unimplemented).returns([])
    @wrench = Local.has_sync {

    }
  end

  it "should send missing methods to syncer" do
    @wrench.syncer.expects(:respond_to?).returns(true)
    @wrench.syncer.expects(:something).returns(something = mock())

    lambda {
      @wrench.something.should == something
    }.should_not raise_error
  end

  it "should raise error for missing methods" do
    lambda {
      @wrench.something
    }.should raise_error(NoMethodError, "undefined method `something' for #{@wrench.inspect}")
  end
end