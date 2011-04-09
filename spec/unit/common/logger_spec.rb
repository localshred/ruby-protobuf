require 'protobuf/common/logger'
require 'stringio'

class << Protobuf::Logger
  def reset_instance
    Protobuf::Logger.file = nil
    Protobuf::Logger.level = nil
    @__instance = nil
  end
end

describe Protobuf::Logger do
  before(:each) do
    Protobuf::Logger.reset_instance
    Protobuf::Logger.file = '/dev/null'
    Protobuf::Logger.level = ::Logger::INFO
  end
  
  context 'when initializing singleton' do
    
    it 'should not create a logger if the file was not set' do
      Protobuf::Logger.file = nil
      Protobuf::Logger.instance.should be_nil
    end
    
    it 'should not create a logger if the level was not set' do
      Protobuf::Logger.level = nil
      Protobuf::Logger.instance.should be_nil
    end
    
    it 'should get a new instance of the logger when file and level are set' do
      Protobuf::Logger.file.should_not be_nil
      Protobuf::Logger.level.should_not be_nil
      Protobuf::Logger.instance.should_not be_nil
    end
    
    it 'should keep the same object from multiple calls to instance' do
      Protobuf::Logger.instance === Protobuf::Logger.instance
    end
    
  end
  
  context 'when logging' do
    
    it 'should not raise errors when log instance is nil' do
      Protobuf::Logger.reset_instance
      Protobuf::Logger.instance.should be_nil
      expect {
        Protobuf::Logger.debug 'No errors here'
        Protobuf::Logger.info 'No errors here'
        Protobuf::Logger.warn 'No errors here'
        Protobuf::Logger.error 'No errors here'
        Protobuf::Logger.fatal 'No errors here'
        Protobuf::Logger.add 'No errors here'
        Protobuf::Logger.log 'No errors here'
      }.should_not raise_error
    end
    
    it 'should log correctly when log instance is valid' do
      Protobuf::Logger.instance.should_not be_nil
      Protobuf::Logger.instance.should_receive(:info).with('Should log great')
      Protobuf::Logger.info 'Should log great'
    end
    
  end
  
end