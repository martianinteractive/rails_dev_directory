require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Endorsement do
  before(:each) do
    @provider = Factory.create(:provider, :aasm_state => 'inactive')
    @endorsement_request_recipient = Factory(:endorsement_request_recipient)
  end

  it "should activate the provider if it is the third endorsement" do
    Notification.stub_chain(:endorsement_notification, :deliver)
    Notification.should_receive(:endorsement_notification).exactly(3).times
    @provider.endorsements << Factory.create(:endorsement, :provider => @provider, :endorsement_request_recipient => @endorsement_request_recipient, :aasm_state => 'approved')
    @provider.status.should == 'inactive'
    @provider.endorsements << Factory.create(:endorsement, :provider => @provider, :endorsement_request_recipient => @endorsement_request_recipient, :aasm_state => 'approved')
    @provider.status.should == 'inactive'
    @provider.endorsements << Factory.create(:endorsement, :provider => @provider, :endorsement_request_recipient => @endorsement_request_recipient, :aasm_state => 'approved')
    @provider.status.should == 'active'
  end
end
