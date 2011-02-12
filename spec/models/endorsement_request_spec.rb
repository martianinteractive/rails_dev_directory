require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EndorsementRequest do
  before(:each) do
    @valid_emails = "paul@rslw.com, btflanagan@gmail.com, trice@ibma.org"
    @complex_emails = "Paul Campbell <paul@rslw.com>, btflanagan@gmail.com, Tony Rice <trice@ibma.org>"
    @too_many_emails = "paul@rslw.com, btflanagan@gmail.com, trice@ibma.org, rand@rslw.com, henry@gmail.com, tstafford@ibma.org, anton@rslw.com, mary@gmail.com, tobrien@ibma.org, alfred@rslw.com, art@gmail.com, nblake@ibma.org"
    # @endorsement_request = EndorsementRequest.new(:message => "Hi there")
    @endorsement_request = Factory.build(:endorsement_request, :recipients => [])
  end

  it "should have an empty array of emails first" do
    @endorsement_request.recipient_addresses.should be_empty
  end
  
  it "should accept emails as a string and convert them to an array" do
    @endorsement_request.recipient_addresses = @valid_emails
    @endorsement_request.recipient_addresses.should == ["paul@rslw.com", "btflanagan@gmail.com", "trice@ibma.org"]
  end
  
  it "should accept complex emails as a string and convert them to an array" do
    @endorsement_request.recipient_addresses = @complex_emails
    @endorsement_request.recipient_addresses.should == ["Paul Campbell <paul@rslw.com>", "btflanagan@gmail.com", "Tony Rice <trice@ibma.org>"]
  end
  
  it "shouldn't be valid without emails" do
    @endorsement_request.should_not be_valid
  end
  
  it "should be valid with valid emails" do
    @endorsement_request.recipient_addresses = @valid_emails
    @endorsement_request.should be_valid
  end
  
  it "should be valid with valid complex emails" do
    @endorsement_request.recipient_addresses = @complex_emails
    @endorsement_request.should be_valid
  end
  
  it "should be invalid with greater than ten valid emails" do
    @endorsement_request.recipient_addresses = @too_many_emails
    @endorsement_request.should_not be_valid
  end
  
  it "should be invalid with invalid emails" do
    @endorsement_request.recipient_addresses = "paul, brian"
    @endorsement_request.should_not be_valid
  end
   
  it "should be invalid with some invalid emails" do
    @endorsement_request.recipient_addresses = "paul, brian@gmail.com"
    @endorsement_request.should_not be_valid
  end
  
end
