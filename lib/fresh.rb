require 'fresh/core_extensions'

module Fresh
  autoload :Syncer, 'fresh/syncer'
  autoload :Wrench, 'fresh/wrench'
  autoload :CoreExtensions, 'fresh/core_extensions'

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def has_sync(name = :default, &blk)
      @syncers ||= {}
      @syncers[name] = build_syncer(blk)
    end

    def syncer(name = :default)
      @syncers[name]
    end

    def sync(name = :default)
      @syncers[name].sync
    end

    protected

    def build_syncer(block)
      instance = Syncer.new
      instance.instance_eval(&block)
      Wrench.new(instance)
    end
  end
end