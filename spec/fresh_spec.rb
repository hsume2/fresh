require 'spec_helper'

describe Fresh do
  before do
    @locals = locals = []
    @remotes = remotes = []

    @syncer = Local.has_sync {
      find_local { locals }
      find_remote { remotes }

      # Get new locals
      fresh_locals do |locals, remotes|
        lh = locals.inject({}) { |hash, local| hash[local.remote_id] = local; hash }
        rh = remotes.inject({}) { |hash, remote| hash[remote.remote_id] = remote; hash }

        (lh - rh).values
      end

      # Get new remotes
      fresh_remotes do |locals, remotes|
        lh = locals.inject({}) { |hash, local| hash[local.remote_id] = local; hash }
        rh = remotes.inject({}) { |hash, remote| hash[remote.remote_id] = remote; hash }

        (rh - lh).values
      end

      #    1: local is fresher
      #   -1: remote is fresher
      #    0: same
      #  nil: not match
      compare_freshness { |local, remote|
        local.freshness <=> remote.freshness if local.remote_id == remote.remote_id
      }

      # Copy new locals to remote
      copy_up { |local, remotes|
        remotes.push Remote.new("R#{rand(99)+2}", local.name, local.content, local.freshness)
      }

      # Copy new remotes to local
      copy_down { |remote, locals|
        locals.push Local.new("L#{rand(99)+2}", remote.remote_id, remote.name, remote.content, remote.freshness)
      }

      # Merge modified local with remote
      merge_up { |local, remote|
        remote.name = local.name
        remote.content = local.content
        remote.freshness = local.freshness
      }

      # Merge modified remote with local
      merge_down { |remote, local|
        local.name = remote.name
        local.content = remote.content
        local.freshness = remote.freshness
      }
    }
  end

  it "should get default syncer" do
    Local.syncer.should == @syncer
  end

  it "should get locals" do
    Local.syncer.locals.should === @locals
  end

  context "with synced" do
    before do
      @locals.unshift Local.new("L1", "R1", "Story 1", "", 10)
      @remotes.unshift Remote.new("R1", "Story 1", "", 10)
    end

    it "should do nothing" do
      sizes = lambda { [@locals.size, @remotes.size] }

      lambda {
        Local.sync
      }.should_not change(sizes, :call)
    end
  end

  context "with new local and empty remote" do
    before do
      @locals.unshift Local.new("L1", "R1", "Story 1", "", 10)
    end

    it "should copy to remote" do
      lambda {
        Local.sync
      }.should change(@remotes, :size).by(1)
    end
  end

  context "with new local and synced" do
    before do
      @locals.push Local.new("L1", "R1", "Story 1", "", 10)
      @locals.push Local.new("L2", "R2", "Story 2", "", 10)
      @remotes.push Remote.new("R1", "Story 1", "", 10)
    end

    it "should copy to remote" do
      lambda {
        Local.sync
      }.should change(@remotes, :size).by(1)
    end
  end

  context "with new remote and empty local" do
    before do
      @remotes.unshift Remote.new("R1", "Story 1", "", 10)
    end

    it "should copy to local" do
      lambda {
        Local.sync
      }.should change(@locals, :size).by(1)
    end
  end

  context "with fresh local and stale remote" do
    before do
      @locals.unshift Local.new("L1", "R1", "First Story", "", 11)
      @remotes.unshift Remote.new("R1", "Story 1", "", 10)
    end

    it "should merge to remote" do
      lambda {
        Local.sync
      }.should change(@remotes.last, :name).from('Story 1').to('First Story')
    end
  end

  context "with fresh remote and stale local" do
    before do
      @locals.unshift Local.new("L1", "R1", "Story 1", "", 10)
      @remotes.unshift Remote.new("R1", "First Story", "", 11)
    end

    it "should merge to local" do
      lambda {
        Local.sync
      }.should change(@locals.last, :name).from('Story 1').to('First Story')
    end
  end

  context "freshness" do
    it "should smell synced" do
      Local.syncer.smell(10, Local.new("L1", "R1", "Story 1", "", 10), Remote.new("R1", "Story 1", "", 10)).should == 0
    end

    it "should smell local fresher" do
      Local.syncer.smell(10, Local.new("L1", "R1", "Story 1", "", 11), Remote.new("R1", "Story 1", "", 10)).should == 1
    end

    it "should smell remote fresher" do
      Local.syncer.smell(10, Local.new("L1", "R1", "Story 1", "", 10), Remote.new("R1", "Story 1", "", 11)).should == -1
    end

    it "should smell nothing" do
      Local.syncer.smell(10, Local.new("L2", "R2", "Story 2", "", 10), Remote.new("R1", "Story 1", "", 10)).should be_nil
    end
  end

  context "helper" do
    it "should merge up" do
      Local.syncer.syncer.merge_up.expects(:call).with(nil, nil)
      Local.syncer.merge_up(nil, nil)
    end
  end

  context "with incomplete syncer" do
    it "should raise error" do
      lambda {
        Local.has_sync {}
      }.should raise_error(Fresh::Syncer::SyncerIncomplete, "Wrench cannot work with incomplete Syncer, please define #{Fresh::Syncer::BlockAttrs.map { |a| ":#{a}"}.join(', ')}")
    end
  end
end
