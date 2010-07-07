# fresh

An infant Ruby DSL for syncing local <=> remote data. i.e.:

    Local.has_sync { # Works on any Ruby Object
      find_local { # Return local array of objects to sync }
      find_remote { # Return remote array of objects to sync }

      fresh_locals do |locals, remotes|
        # Return array of locals that are fresh (exist locally, but not remotely)
      end

      fresh_remotes do |locals, remotes|
        # Return array of remotes that are fresh (exist remotely, but not locally)
      end

      copy_up do |local, remotes|
        # Copy new locals to remote
      end

      copy_down do |remote, locals|
        # Copy new remotes to local
      end

      # For all local and remote (this could be more efficient)
      compare_freshness do |local, remote|
        #  Return:
        #    1: local is fresher     # => Merge up
        #   -1: remote is fresher    # => Merge down
        #    0: same                 # => Currently does nothing
        #  nil: not match            # => Currently does nothing
      end

      merge_up { |local, remote|
        # Merge modified local with remote
      }

      merge_down { |remote, local|
        # Merge modified remote with local
      }
    }
    
    # Whenever you want to sync
    Local.sync
    
    # In case you're curious what you're syncing
    Local.locals
    Local.remotes

### Motivation

I created this gem to simplify tracking remote changes in Pivotal Tracker. I also use it to persist various information between our local DB and Pivotal Tracker.
Over time, this gem should evolve into a more robust, usable solution.

*****

# Copyright

Copyright (c) 2010 Henry Hsu. See LICENSE for details.