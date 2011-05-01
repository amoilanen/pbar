#
# Simple utility for reporting progress.
#
# Copyright (c) 2011 Anton Ivanov anton.al.ivanov(no spam)gmail.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require File.expand_path(File.dirname(__FILE__) + '/../lib/progress_bar.rb')
require 'test/unit'

class MockTimer

    def start
    end

    def set(counter)
	@counter = counter
	self
    end

    def elapsed
	@counter
    end
end

class BarTest < Test::Unit::TestCase
 
  def setup
    @timer = MockTimer.new.set(1)
  end

  def test_progress_is_zero_in_the_beginning
    @bar = Progress::Bar.new(:total =>1, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    @bar.start
    assert_equal(Progress::Status.new(:donePercent => 0, :todoPercent => 100, :speed => 0), 
                       @bar.getStatus)
  end
  
  def test_some_progress_have_been_made
    @bar = Progress::Bar.new(:total =>2, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    @bar.start
    @bar.increment
    assert_equal(Progress::Status.new(:donePercent => 50, :todoPercent => 50, :speed => 1),
                        @bar.getStatus)
  end
  
  def test_speed_is_calculated_as_time_passes
    @bar = Progress::Bar.new(:total =>100, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    @bar.increment(20)
    (1..10).each do |time_elapsed|
	@timer.set(time_elapsed)
        assert_equal(Progress::Status.new(:donePercent => 20, :todoPercent => 80, :speed => 20 / time_elapsed),
                        @bar.getStatus)    
    end
  end

  def test_units_per_item_can_be_used_to_scale_speed
    @bar = Progress::Bar.new(:total =>2, :unitsPerItem => 100, :unitName => "", :timer => @timer)
    @bar.start
    @bar.increment
    assert_equal(Progress::Status.new(:donePercent => 50, :todoPercent => 50, :speed => 100),
                        @bar.getStatus)
  end

  def test_all_progress_have_been_made
    @bar = Progress::Bar.new(:total =>100, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    @bar.start
    @bar.increment(100)
    assert_equal(Progress::Status.new(:donePercent => 100, :todoPercent => 0, :speed => 100),
                        @bar.getStatus)
  end

  def test_all_progress_have_been_made_additional_increments_are_ignored
    @bar = Progress::Bar.new(:total =>100, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    @bar.start
    @bar.increment(100)

    @bar.increment(1)
    assert_equal(Progress::Status.new(:donePercent => 100, :todoPercent => 0, :speed => 100),
                        @bar.getStatus)
  end

  def test_zero_seconds_elapsed
    @bar = Progress::Bar.new(:total =>1, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    @bar.start
    @bar.increment
    @timer.set(0)
    assert_equal(Progress::Status.new(:donePercent => 100, :todoPercent => 0, :speed => "n/a"), 
                       @bar.getStatus)
  end

  def test_negative_or_zero_values_not_allowed_for_total_unitsPerItem
    assert_raise(RuntimeError) { Progress::Bar.new(:total =>0, :unitsPerItem => 1, :unitName => "", :timer => @timer) }
    assert_raise(RuntimeError) { Progress::Bar.new(:total =>-1, :unitsPerItem => 1, :unitName => "", :timer => @timer) }
    assert_raise(RuntimeError) { Progress::Bar.new(:total =>1, :unitsPerItem => 0, :unitName => "", :timer => @timer) }
    assert_raise(RuntimeError) { Progress::Bar.new(:total =>1, :unitsPerItem => -1, :unitName => "", :timer => @timer) }
  end
 end