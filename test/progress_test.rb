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

class InMemoryReporter
  
  attr_reader :statuses, :finished, :aborted
  
  def initialize
    @statuses = []
    @finished = false
    @aborted = false
  end
  
  def onStatus(status)
    statuses << status
  end
  
  def onFinished
    @finished = true
  end
  
  def onAborted
    @aborted = true
  end
end

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
    progress = PBar::Progress.new(1, @timer)
    progress.start
    assert_equal(PBar::Status.new(:donePercent => 0, :todoPercent => 100, :timeElapsed => 1), 
                       progress.getStatus)
  end
  
  def test_when_a_few_calls_to_increment_have_been_made_then_it_is_reflected_in_status
    progress = PBar::Progress.new(2, @timer)
    progress.start
    progress.increment
    assert_equal(PBar::Status.new(:donePercent => 50, :todoPercent => 50, :timeElapsed => 1),
                        progress.getStatus)
  end
  
  def test_when_time_passes_and_no_calls_to_increment_are_made_then_the_resulting_status_changes
    progress = PBar::Progress.new(100, @timer)
    progress.increment(20)
    [2, 3, 4, 5, 6].each do |time_elapsed|
      @timer.set(time_elapsed)
      assert_equal(PBar::Status.new(:donePercent => 20, :todoPercent => 80, :timeElapsed => time_elapsed),
          progress.getStatus)
    end
  end

  def test_when_time_passes_and_a_few_calls_to_increment_are_made_then_the_resulting_status_changes
    progress = PBar::Progress.new(10, @timer)
    
    progress.increment(4)
    @timer.set(2)
    assert_equal(PBar::Status.new(:donePercent => 40, :todoPercent => 60, :timeElapsed => 2),
                        progress.getStatus)

    progress.increment(2)
    @timer.set(6)
    assert_equal(PBar::Status.new(:donePercent => 60, :todoPercent => 40, :timeElapsed => 6),
                        progress.getStatus)
  end

  def test_when_increments_other_than_1_are_made_then_they_are_reflected_in_calculated_status
    progress = PBar::Progress.new(4, @timer)
    progress.start
    
    progress.increment
    assert_equal(PBar::Status.new(:donePercent => 25, :todoPercent => 75, :timeElapsed => 1),
                        progress.getStatus)
    progress.increment(3)
    assert_equal(PBar::Status.new(:donePercent => 100, :todoPercent => 0, :timeElapsed => 1),
                        progress.getStatus)
  end
  
  def test_when_increment_with_negative_or_zero_argument_is_called_then_an_exception_is_raised
    progress = PBar::Progress.new(1, @timer)
    progress.start
    
    assert_raise(RuntimeError) do
      progress.increment(0)
    end
    assert_raise(RuntimeError) do
      progress.increment(-1)
    end
  end

  def test_when_all_progress_have_been_made_then_it_is_reflected_in_status
    progress = PBar::Progress.new(100, @timer)
    progress.start
    progress.increment(100)
    assert_equal(PBar::Status.new(:donePercent => 100, :todoPercent => 0, :timeElapsed => 1),
                        progress.getStatus)
  end

  def test_when_all_progress_have_been_made_then_additional_increments_are_ignored
    progress = PBar::Progress.new(100, @timer)
    progress.start
    progress.increment(100)

    progress.increment(1)
    assert_equal(PBar::Status.new(:donePercent => 100, :todoPercent => 0, :timeElapsed => 1),
                        progress.getStatus)
  end
  
  def test_when_negative_or_zero_values_are_provided_for_total_then_exception_is_raised
    assert_raise(RuntimeError) do 
      PBar::Progress.new(0, @timer)
    end
    assert_raise(RuntimeError) do 
      PBar::Progress.new(-1, @timer)
    end
  end
  
  def test_when_one_listener_is_added_and_a_few_increment_calls_were_made_then_listener_is_notified_of_calls
    reporter = InMemoryReporter.new
    progress = PBar::Progress.new(10, @timer)
    progress.listeners << reporter 

    progress.start
    (1..3).each do
      progress.increment
    end
    
    assert_equal(
      [PBar::Status.new(:donePercent => 10, :todoPercent => 90, :timeElapsed => 1),
        PBar::Status.new(:donePercent => 20, :todoPercent => 80, :timeElapsed => 1),
        PBar::Status.new(:donePercent => 30, :todoPercent => 70, :timeElapsed => 1)],
      reporter.statuses)
  end
  
  def test_when_one_listener_is_added_then_it_is_notified_of_progress_finish_progress_has_all_been_made
    reporter = InMemoryReporter.new
    progress = PBar::Progress.new(1, @timer)
    progress.listeners << reporter

    progress.start
    progress.increment
    
    assert_equal(
      [PBar::Status.new(:donePercent => 100, :todoPercent => 0, :timeElapsed => 1)],
      reporter.statuses)
    assert(reporter.finished)
  end

  #TODO: Test that notification on finish is done only once
  #TODO: increment, finished, increment not allowed
  #TODO: increment, finished, abort not allowed
  
  #TODO: Test aborting a progress
  #TODO: abort, abort not allowed
  #TODO: increment, abort, increment not allowed
  #TODO: increment, abort, finished not allowed
  
  def test_when_a_few_listeners_are_added_and_a_few_increment_calls_were_made_then_listeners_are_notified_of_calls
    reportersNumber = 5
    reporters = [] 
    (1..reportersNumber).each do |i|
      reporters[i] = InMemoryReporter.new
    end
    
    progress = PBar::Progress.new(10, @timer)
    
    (1..reportersNumber).each do |i|
      progress.listeners << reporters[i]
    end

    progress.start
    (1..3).each do
      progress.increment
    end
  
    (1..reportersNumber).each do |i|
      assert_equal(
        [PBar::Status.new(:donePercent => 10, :todoPercent => 90, :timeElapsed => 1),
          PBar::Status.new(:donePercent => 20, :todoPercent => 80, :timeElapsed => 1),
          PBar::Status.new(:donePercent => 30, :todoPercent => 70, :timeElapsed => 1)],
        reporters[i].statuses)
    end
  end
end