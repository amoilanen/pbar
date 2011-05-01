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

require 'pbar/progress_bar'
require 'test/unit'

class FixedTimeTimer

  attr_reader :elapsed
  
  def start
  end

  def set(elapsed)
    @elapsed = elapsed
    self
  end
end

class ProgressTest < Test::Unit::TestCase
 
  def setup
    @timer = FixedTimeTimer.new.set(1)
  end

  def test_when_no_increment_calls_were_made_then_progress_is_zero
    @bar = PBar::Progress.new(:total => 1, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    @bar.start
    assert_equal(PBar::Status.new(:donePercent => 0, :todoPercent => 100, :speed => 0), 
                       @bar.getStatus)
  end
  
  def test_when_a_few_calls_to_increment_have_been_made_then_it_is_reflected_in_status
    @bar = PBar::Progress.new(:total => 2, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    @bar.start
    @bar.increment
    assert_equal(PBar::Status.new(:donePercent => 50, :todoPercent => 50, :speed => 1),
                        @bar.getStatus)
  end
  
  def test_when_time_passes_and_no_calls_to_increment_are_made_then_speed_in_the_resulting_status_changes
    @bar = PBar::Progress.new(:total => 100, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    @bar.increment(20)
    [2, 4, 5, 10, 20].each do |time_elapsed|
      @timer.set(time_elapsed)
      assert_equal(PBar::Status.new(:donePercent => 20, :todoPercent => 80, :speed => 20 / time_elapsed),
                        @bar.getStatus)
    end
  end

  #TODO: Test the case when both increment is called and time passes 
  
  def test__when_units_per_item_is_specified_then_it_is_used_when_computing_speed
    @bar = PBar::Progress.new(:total => 2, :unitsPerItem => 100, :unitName => "", :timer => @timer)
    @bar.start
    @bar.increment
    assert_equal(PBar::Status.new(:donePercent => 50, :todoPercent => 50, :speed => 100),
                        @bar.getStatus)
  end

  def test_when_all_progress_have_been_made_then_it_is_reflected_in_status
    @bar = PBar::Progress.new(:total =>100, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    @bar.start
    @bar.increment(100)
    assert_equal(PBar::Status.new(:donePercent => 100, :todoPercent => 0, :speed => 100),
                        @bar.getStatus)
  end

  def test_when_all_progress_have_been_made_then_additional_increments_are_ignored
    @bar = PBar::Progress.new(:total =>100, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    @bar.start
    @bar.increment(100)

    @bar.increment(1)
    assert_equal(PBar::Status.new(:donePercent => 100, :todoPercent => 0, :speed => 100),
                        @bar.getStatus)
  end

  def test_when_no_time_elapsed_then_status_is_calculated_correctly
    @bar = PBar::Progress.new(:total =>1, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    @bar.start
    @bar.increment
    @timer.set(0)
    assert_equal(PBar::Status.new(:donePercent => 100, :todoPercent => 0, :speed => "n/a"), 
                       @bar.getStatus)
  end

  def test_negative_or_zero_values_not_allowed_for_total_unitsPerItem
    assert_raise(RuntimeError) do 
      PBar::Progress.new(:total =>0, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    end
    assert_raise(RuntimeError) do 
      PBar::Progress.new(:total =>-1, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    end
    assert_raise(RuntimeError) do 
      PBar::Progress.new(:total =>1, :unitsPerItem => 0, :unitName => "", :timer => @timer)
    end
    assert_raise(RuntimeError) do 
      PBar::Progress.new(:total =>1, :unitsPerItem => -1, :unitName => "", :timer => @timer)
    end
  end
  
  #TODO: Test that progress listeners are notified
  #TODO: Test that progress listeners are still notified even when the finish is reached
 end
 
 #TODO: Test that different reporters are notified:
 #- no listeners
 #- one listener (by default ConsoleReporter)
 #- several listeners
 
class StatusTest < Test::Unit::TestCase

   def test_when_donePercent_todoPercent_are_less_than_zero_then_exception_raised
     assert_raise(RuntimeError) do 
       PBar::Status.new(:donePercent => -10, :todoPercent => 110, :speed => 0)
     end
     assert_raise(RuntimeError) do 
       PBar::Status.new(:donePercent => 110, :todoPercent => -10, :speed => 0)
     end
   end

   def test_when_other_status_has_same_fields_then_statuses_are_equal
     this = PBar::Status.new(:donePercent => 30, :todoPercent => 40, :speed => 50)
     that = PBar::Status.new(:donePercent => 30, :todoPercent => 40, :speed => 50)

     assert_equal(this, that)
   end

   def test_when_other_status_has_different_fields_then_statuses_are_not_equal
     this = PBar::Status.new(:donePercent => 30, :todoPercent => 40, :speed => 50)
     that = PBar::Status.new(:donePercent => 30, :todoPercent => 20, :speed => 50)
  
     assert_not_equal(this, that)
   end
end