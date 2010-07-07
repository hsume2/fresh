module Fresh
  class Wrench
    attr_reader :syncer

    def initialize(syncer)
      @syncer = syncer
      Syncer.ensure_syncer_complete(@syncer)
    end

    def smell(freshness, local, remote)
      @syncer.compare_freshness.call(local, remote)
    end

    def sync
      locs, rmts = locals, remotes
      
      @syncer.fresh_locals.call(locs, rmts).each do |local|
        @syncer.copy_up.call(local, rmts)
      end
      @syncer.fresh_remotes.call(locs, rmts).each do |remote|
        @syncer.copy_down.call(remote, locs)
      end

      locs.each do |local|
        rmts.each do |remote|
          case smell(nil, local, remote)
          when 1 # Merge up
            @syncer.merge_up.call(local, remote)
          when -1 # Merge down
            @syncer.merge_down.call(remote, local)
          when 0 # Synced
          end
        end
      end
    end

    def locals
      @syncer.find_local.call
    end
    def remotes
      @syncer.find_remote.call
    end

    def merge_up(local, remote)
      @syncer.merge_up.call(local, remote)
    end

    # Delegates methods to the current syncer
    def method_missing(*args, &blk)
      if @syncer.respond_to?(args.first)
        @syncer.send(*args, &blk)
      else
        super(*args, &blk)
      end
    end
  end
end