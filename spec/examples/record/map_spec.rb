require File.expand_path('../spec_helper', __FILE__)

describe Cequel::Record::Map do
  model :Post do
    key :permalink, :text
    column :title, :text
    map :likes, :text, :int
  end

  let(:scope) { cequel[:posts].where(:permalink => 'cequel') }
  subject { scope.first }

  let! :post do
    Post.new do |post|
      post.permalink = 'cequel'
      post.likes = {'alice' => 1, 'bob' => 2}
    end.tap(&:save)
  end

  let! :unloaded_post do
    Post['cequel']
  end

  context 'new record' do
    it 'should save set as-is' do
      subject[:likes].should == {'alice' => 1, 'bob' => 2}
    end
  end

  describe 'atomic modification' do
    before { scope.map_update(:likes, 'charles' => 3) }

    describe '#[]=' do
      it 'should atomically update' do
        post.likes['david'] = 4
        post.save
        subject[:likes].should == 
          {'alice' => 1, 'bob' => 2, 'charles' => 3, 'david' => 4}
        post.likes.should == {'alice' => 1, 'bob' => 2, 'david' => 4}
      end

      it 'should write without reading' do
        max_statements! 2
        unloaded_post.likes['david'] = 4
        unloaded_post.save
        subject[:likes].should ==
          {'alice' => 1, 'bob' => 2, 'charles' => 3, 'david' => 4}
      end

      it 'should set key value post-hoc' do
        unloaded_post.likes['david'] = 4
        unloaded_post.likes.should ==
          {'alice' => 1, 'bob' => 2, 'charles' => 3, 'david' => 4}
      end
    end

    describe '#clear' do
      it 'should atomically clear' do
        post.likes.clear
        post.save
        subject[:likes].should be_blank
        post.likes.should == {}
      end

      it 'should clear without reading' do
        max_statements! 2
        unloaded_post.likes.clear
        unloaded_post.save
        subject[:likes].should be_blank
      end

      it 'should clear post-hoc' do
        unloaded_post.likes.clear
        unloaded_post.likes.should be_blank
      end
    end

    describe '#delete' do
      it 'should delete element atomically' do
        post.likes.delete('bob')
        post.save
        subject[:likes].should == {'alice' => 1, 'charles' => 3}
        post.likes.should == {'alice' => 1}
      end

      it 'should delete without reading' do
        max_statements! 2
        unloaded_post.likes.delete('bob')
        unloaded_post.save
        subject[:likes].should == {'alice' => 1, 'charles' => 3}
      end

      it 'should delete post-hoc' do
        unloaded_post.likes.delete('bob')
        unloaded_post.likes.should == {'alice' => 1, 'charles' => 3}
      end
    end

    describe '#merge!' do
      it 'should atomically update' do
        post.likes.merge!('david' => 4, 'emily' => 5)
        post.save
        subject[:likes].should == 
          {'alice' => 1, 'bob' => 2, 'charles' => 3, 'david' => 4, 'emily' => 5}
        post.likes.should ==
          {'alice' => 1, 'bob' => 2, 'david' => 4, 'emily' => 5}
      end

      it 'should write without reading' do
        max_statements! 2
        unloaded_post.likes.merge!('david' => 4, 'emily' => 5)
        unloaded_post.save
        subject[:likes].should ==
          {'alice' => 1, 'bob' => 2, 'charles' => 3, 'david' => 4, 'emily' => 5}
      end

      it 'should merge post-hoc' do
        unloaded_post.likes.merge!('david' => 4, 'emily' => 5)
        unloaded_post.likes.should ==
          {'alice' => 1, 'bob' => 2, 'charles' => 3, 'david' => 4, 'emily' => 5}
      end
    end

    describe '#replace' do
      it 'should automatically overwrite' do
        post.likes.replace('david' => 4, 'emily' => 5)
        post.save
        subject[:likes].should == {'david' => 4, 'emily' => 5}
        post.likes.should == {'david' => 4, 'emily' => 5}
      end

      it 'should overwrite without reading' do
        max_statements! 2
        unloaded_post.likes.replace('david' => 4, 'emily' => 5)
        unloaded_post.save
        subject[:likes].should == {'david' => 4, 'emily' => 5}
      end

      it 'should replace post-hoc' do
        unloaded_post.likes.replace('david' => 4, 'emily' => 5)
        unloaded_post.likes.should == {'david' => 4, 'emily' => 5}
      end
    end

    describe '#store' do
      it 'should atomically update' do
        post.likes.store('david', 4)
        post.save
        subject[:likes].should == 
          {'alice' => 1, 'bob' => 2, 'charles' => 3, 'david' => 4}
        post.likes.should == {'alice' => 1, 'bob' => 2, 'david' => 4}
      end

      it 'should write without reading' do
        max_statements! 2
        unloaded_post.likes.store('david', 4)
        unloaded_post.save
        subject[:likes].should == 
          {'alice' => 1, 'bob' => 2, 'charles' => 3, 'david' => 4}
      end

      it 'should store post-hoc' do
        unloaded_post.likes.store('david', 4)
        unloaded_post.likes.should == 
          {'alice' => 1, 'bob' => 2, 'charles' => 3, 'david' => 4}
      end
    end

    describe '#update' do
      it 'should atomically update' do
        post.likes.update('david' => 4, 'emily' => 5)
        post.save
        subject[:likes].should == 
          {'alice' => 1, 'bob' => 2, 'charles' => 3, 'david' => 4, 'emily' => 5}
        post.likes.should ==
          {'alice' => 1, 'bob' => 2, 'david' => 4, 'emily' => 5}
      end

      it 'should write without reading' do
        max_statements! 2
        unloaded_post.likes.update('david' => 4, 'emily' => 5)
        unloaded_post.save
        subject[:likes].should == 
          {'alice' => 1, 'bob' => 2, 'charles' => 3, 'david' => 4, 'emily' => 5}
      end

      it 'should update post-hoc' do
        unloaded_post.likes.update('david' => 4, 'emily' => 5)
        unloaded_post.likes.should == 
          {'alice' => 1, 'bob' => 2, 'charles' => 3, 'david' => 4, 'emily' => 5}
      end
    end

    specify { expect { post.likes.default }.to raise_error(NoMethodError) }
    specify { expect { post.likes.default = 1 }.to raise_error(NoMethodError) }
    specify { expect { post.likes.default_proc }.to raise_error(NoMethodError) }
    specify { expect { post.likes.default_proc = -> k, v { Time.now }}.
      to raise_error(NoMethodError) }
    specify { expect { post.likes.delete_if { |k, v| v.even? }}.
      to raise_error(NoMethodError) }
    specify { expect { post.likes.deep_merge!('alice' => 5) }.
      to raise_error(NoMethodError) }
    specify { expect { post.likes.except!('alice') }.
      to raise_error(NoMethodError) }
    specify { expect { post.likes.extract!('alice') }.
      to raise_error(NoMethodError) }
    specify { expect { post.likes.transform_keys!(&:upcase) }.
      to raise_error(NoMethodError) }
    specify { expect { post.likes.keep_if { |k, v| v.even? }}.
      to raise_error(NoMethodError) }
    specify { expect { post.likes.reject! { |k, v| v.even? }}.
      to raise_error(NoMethodError) }
    specify { expect { post.likes.reverse_merge!('alice' => 3) }.
      to raise_error(NoMethodError) }
    specify { expect { post.likes.reverse_update('alice' => 3) }.
      to raise_error(NoMethodError) }
    specify { expect { post.likes.select! { |k, v| v.even? }}.
      to raise_error(NoMethodError) }
    specify { expect { post.likes.shift }.to raise_error(NoMethodError) }
    specify { expect { post.likes.stringify_keys! }.
      to raise_error(NoMethodError) }
    specify { expect { post.likes.symbolize_keys! }.
      to raise_error(NoMethodError) }
    specify { expect { post.likes.to_options! }.
      to raise_error(NoMethodError) }
    specify { expect { post.likes.slice!('alice') }.
      to raise_error(NoMethodError) }
  end
end
