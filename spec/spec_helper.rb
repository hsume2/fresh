$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'fresh'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

class Local < Struct.new(:local_id, :remote_id, :name, :content, :freshness)
  include Fresh

  def ==(other)
    case other
    when Local
      super(other)
    when Remote
      self.remote_id == other.remote_id &&
        self.name == other.name &&
        self.content == other.content
    end
  end
end

class Remote < Struct.new(:remote_id, :name, :content, :freshness)
  def ==(other)
    case other
    when Remote
      super(other)
    when Local
      other == self
    end
  end
end