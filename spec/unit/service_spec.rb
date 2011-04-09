require 'spec_helper'
require 'spec/proto/test_service_impl'

describe Protobuf::Rpc::Service do
  
  context 'when configuring' do
    before :each do
      reset_service_location Spec::Proto::TestService
    end
  
    it 'should have a default location configured' do
      Spec::Proto::TestService.host.should == Protobuf::Rpc::Service::DEFAULT_LOCATION[:host]
      Spec::Proto::TestService.port.should == Protobuf::Rpc::Service::DEFAULT_LOCATION[:port]
    end
  
    it "should be able to pre-configure a service location for clients" do
      Spec::Proto::TestService.located_at 'google.com:12345'
      client = Spec::Proto::TestService.client
      client.options[:host].should == 'google.com'
      client.options[:port].should == 12345
    end
  
    it 'should be able to configure and read the host' do
      Spec::Proto::TestService.configure :host => 'somehost.com'
      Spec::Proto::TestService.host.should == 'somehost.com'
    end
  
    it 'should be able to configure and read the port' do
      Spec::Proto::TestService.configure :port => 12345
      Spec::Proto::TestService.port.should == 12345
    end
  
    it 'should skip configuring location if the location passed does not match host:port syntax' do
      invalid_locations = [nil, 'myhost:', ':9939', 'badhost123']
      invalid_locations.each do |location|
        Spec::Proto::TestService.located_at location
        Spec::Proto::TestService.host.should == Protobuf::Rpc::Service::DEFAULT_LOCATION[:host]
        Spec::Proto::TestService.port.should == Protobuf::Rpc::Service::DEFAULT_LOCATION[:port]
      end
    end
  end
  
end