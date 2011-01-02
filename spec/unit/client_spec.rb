require 'spec_helper'
require 'spec/proto/test_service_impl'

describe Protobuf::Rpc::Client do
  
  context 'when creating a client from a service' do
    
    it 'should be able to get a client through the Service#client helper method' do
      Spec::Proto::TestService.client(:port => 9191).should == Protobuf::Rpc::Client.new(:service => Spec::Proto::TestService, :port => 9191)
    end
    
    it "should be able to override a service location's host and port" do
      Spec::Proto::TestService.located_at 'somewheregreat.com:12345'
      clean_client = Spec::Proto::TestService.client
      clean_client.options[:host].should == 'somewheregreat.com'
      clean_client.options[:port].should == 12345
      
      updated_client = Spec::Proto::TestService.client(:host => 'amazing.com', :port => 54321)
      updated_client.options[:host].should == 'amazing.com'
      updated_client.options[:port].should == 54321
    end
    
    it 'should be able to define the syncronicity of the client request' do
      client = Spec::Proto::TestService.client(:async => false)
      client.options[:async].should be_false
      client.do_block.should be_true
      
      client = Spec::Proto::TestService.client(:async => true)
      client.options[:async].should be_true
      client.do_block.should be_false
    end
    
    it 'should be able to define which service to create itself for' do
      client = Protobuf::Rpc::Client.new :service => Spec::Proto::TestService
      client.options[:service].should == Spec::Proto::TestService
    end
    
    it 'should have a hard default for host and port on a service that has not been configured' do
      reset_service_location Spec::Proto::TestService
      client = Spec::Proto::TestService.client
      client.options[:host].should == Protobuf::Rpc::Service::DEFAULT_LOCATION[:host]
      client.options[:port].should == Protobuf::Rpc::Service::DEFAULT_LOCATION[:port]
    end

  end
  
  context 'when calling methods on a service client' do
    
    # NOTE: we are assuming the service methods are accurately 
    # defined inside spec/proto/test_service.rb,
    # namely the :find method
    
    it 'should respond to defined service methods' do
      client = Spec::Proto::TestService.client
      client.should_receive(:call_rpc).and_return(nil)
      expect { client.find(nil) }.should_not raise_error
    end
    
    it 'should be able to set and get local variables within client response blocks' do
      outer_value = 'OUTER'
      inner_value = 'INNER'
      client = Spec::Proto::TestService.client(:async => true)
      
      EM.should_receive(:reactor_running?).and_return(true)
      EM.stub!(:schedule) do
        client.instance_variable_get(:@success_callback).call(inner_value)
      end
      
      client.find(nil) do |c|
        c.on_success do |response|
          outer_value.should == 'OUTER'
          outer_value = response
        end
      end
      outer_value.should == inner_value
    end
    
  end
  
end