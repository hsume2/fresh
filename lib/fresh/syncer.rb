module Fresh
  class Syncer
    BlockAttrs = [:find_local, :find_remote, :compare_freshness, :copy_up, :copy_down, :merge_up, :merge_down, :fresh_locals, :fresh_remotes]
    
    BlockAttrs.each do |att|
      attr_reader att
      define_method att do |&blk|
        instance_variable_get(:"@#{att}") || instance_variable_set(:"@#{att}", blk)
      end
    end

    class SyncerIncomplete < Exception; end

    class << self
      def ensure_syncer_complete(syncer)
        unimp = unimplemented(syncer)
        raise SyncerIncomplete, "Wrench cannot work with incomplete Syncer, please define #{unimp.map{ |s| ":#{s}" }.join(', ')}" unless unimp.empty?
      end

      def unimplemented(syncer)
        Syncer::BlockAttrs.inject([]) do |ui, att|
          ui << att if syncer.send(att).nil?
          ui
        end
      end
    end
  end
end