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
require 'stringio'

class FixedTimeTimer

  attr_reader :elapsed
  
  def start
  end

  def set(elapsed)
    @elapsed = elapsed
    self
  end
end

class InMemoryReporter
  
  attr_reader :statuses
  
  def initialize
    @statuses = []
  end
  
  def onStatus(status)
    statuses << status
  end
end

class IndentityRenderer
  
  def render(status)
    status
  end
end

class ProgressTest < Test::Unit::TestCase
 
  def setup
    @timer = FixedTimeTimer.new.set(1)
  end

  def test_when_no_increment_calls_were_made_then_progress_is_zero
    progress = PBar::Progress.new(:total => 1, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    progress.start
    assert_equal(PBar::Status.new(:donePercent => 0, :todoPercent => 100, :speed => 0), 
                       progress.getStatus)
  end
  
  def test_when_a_few_calls_to_increment_have_been_made_then_it_is_reflected_in_status
    progress = PBar::Progress.new(:total => 2, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    progress.start
    progress.increment
    assert_equal(PBar::Status.new(:donePercent => 50, :todoPercent => 50, :speed => 1),
                        progress.getStatus)
  end
  
  def test_when_time_passes_and_no_calls_to_increment_are_made_then_speed_in_the_resulting_status_changes
    progress = PBar::Progress.new(:total => 100, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    progress.increment(20)
    [2, 4, 5, 10, 20].each do |time_elapsed|
      @timer.set(time_elapsed)
      assert_equal(PBar::Status.new(:donePercent => 20, :todoPercent => 80, :speed => 20 / time_elapsed),
                        progress.getStatus)
    end
  end

  def test_when_time_passes_and_a_few_calls_to_increment_are_made_then_the_resulting_status_changes
    progress = PBar::Progress.new(:total => 10, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    
    progress.increment(4)
    @timer.set(2)
    assert_equal(PBar::Status.new(:donePercent => 40, :todoPercent => 60, :speed => 2),
                        progress.getStatus)

    progress.increment(2)
    @timer.set(6)
    assert_equal(PBar::Status.new(:donePercent => 60, :todoPercent => 40, :speed => 1),
                        progress.getStatus)
  end

  def test_when_increments_other_than_1_are_made_then_they_are_reflected_in_calculated_status
    progress = PBar::Progress.new(:total => 4, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    progress.start
    
    progress.increment
    assert_equal(PBar::Status.new(:donePercent => 25, :todoPercent => 75, :speed => 1),
                        progress.getStatus)
    progress.increment(3)
    assert_equal(PBar::Status.new(:donePercent => 100, :todoPercent => 0, :speed => 4),
                        progress.getStatus)
  end
  
  def test_when_increment_with_negative_or_zero_argument_is_called_then_an_exception_is_raised
    progress = PBar::Progress.new(:total => 1, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    progress.start
    
    assert_raise(RuntimeError) do
      progress.increment(0)
    end
    assert_raise(RuntimeError) do
      progress.increment(-1)
    end
  end
  
  def test_when_units_per_item_is_specified_then_it_is_used_when_computing_speed
    progress = PBar::Progress.new(:total => 2, :unitsPerItem => 100, :unitName => "", :timer => @timer)
    progress.start
    progress.increment
    assert_equal(PBar::Status.new(:donePercent => 50, :todoPercent => 50, :speed => 100),
                        progress.getStatus)
  end

  def test_when_all_progress_have_been_made_then_it_is_reflected_in_status
    progress = PBar::Progress.new(:total => 100, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    progress.start
    progress.increment(100)
    assert_equal(PBar::Status.new(:donePercent => 100, :todoPercent => 0, :speed => 100),
                        progress.getStatus)
  end

  def test_when_all_progress_have_been_made_then_additional_increments_are_ignored
    progress = PBar::Progress.new(:total => 100, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    progress.start
    progress.increment(100)

    progress.increment(1)
    assert_equal(PBar::Status.new(:donePercent => 100, :todoPercent => 0, :speed => 100),
                        progress.getStatus)
  end

  def test_when_no_time_elapsed_then_status_is_calculated_correctly
    progress = PBar::Progress.new(:total => 1, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    progress.start
    progress.increment
    @timer.set(0)
    assert_equal(PBar::Status.new(:donePercent => 100, :todoPercent => 0, :speed => PBar::Progress::UNKNOWN_SPEED), 
                       progress.getStatus)
  end
  
  def test_when_negative_or_zero_values_are_provided_for_total_unitsPerItem_then_exception_is_raised
    assert_raise(RuntimeError) do 
      PBar::Progress.new(:total => 0, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    end
    assert_raise(RuntimeError) do 
      PBar::Progress.new(:total => -1, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    end
    assert_raise(RuntimeError) do 
      PBar::Progress.new(:total => 1, :unitsPerItem => 0, :unitName => "", :timer => @timer)
    end
    assert_raise(RuntimeError) do 
      PBar::Progress.new(:total => 1, :unitsPerItem => -1, :unitName => "", :timer => @timer)
    end
  end
  
  def test_when_one_listener_is_added_and_a_few_increment_calls_were_made_then_listener_is_notified_of_calls
    reporter = InMemoryReporter.new
    progress = PBar::Progress.new(:total => 10, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    progress.listeners << reporter 

    progress.start
    (1..3).each do
      progress.increment
    end
    
    assert_equal(
      [PBar::Status.new(:donePercent => 10, :todoPercent => 90, :speed => 1),
        PBar::Status.new(:donePercent => 20, :todoPercent => 80, :speed => 2),
        PBar::Status.new(:donePercent => 30, :todoPercent => 70, :speed => 3)],
      reporter.statuses)
  end
  
  def test_when_one_listener_is_added_then_it_is_notified_even_after_progress_has_all_been_made
    reporter = InMemoryReporter.new
    progress = PBar::Progress.new(:total => 1, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    progress.listeners << reporter

    progress.start
    progress.increment
    progress.increment
    
    assert_equal(
      [PBar::Status.new(:donePercent => 100, :todoPercent => 0, :speed => 1),
        PBar::Status.new(:donePercent => 100, :todoPercent => 0, :speed => 1)],
      reporter.statuses)
  end

  def test_when_a_few_listeners_are_added_and_a_few_increment_calls_were_made_then_listeners_are_notified_of_calls
    reportersNumber = 5
    reporters = [] 
    (1..reportersNumber).each do |i|
      reporters[i] = InMemoryReporter.new
    end
    
    progress = PBar::Progress.new(:total => 10, :unitsPerItem => 1, :unitName => "", :timer => @timer)
    
    (1..reportersNumber).each do |i|
      progress.listeners << reporters[i]
    end

    progress.start
    (1..3).each do
      progress.increment
    end
  
    (1..reportersNumber).each do |i|
      assert_equal(
        [PBar::Status.new(:donePercent => 10, :todoPercent => 90, :speed => 1),
          PBar::Status.new(:donePercent => 20, :todoPercent => 80, :speed => 2),
          PBar::Status.new(:donePercent => 30, :todoPercent => 70, :speed => 3)],
        reporters[i].statuses)
    end
  end
end
 
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
     that = PBar::Status.new(:donePercent => 30, :todoPercent => 40, :speed => 50, :unitName => "unitname")
     this = PBar::Status.new(:donePercent => 30, :todoPercent => 40, :speed => 50, :unitName => "unitname")

     assert_equal(this, that)
   end

   def test_when_other_status_has_different_fields_then_statuses_are_not_equal
     this = PBar::Status.new(:donePercent => 30, :todoPercent => 40, :speed => 50, :unitName => "unitname")
     that = PBar::Status.new(:donePercent => 30, :todoPercent => 20, :speed => 50, :unitName => "unitname")
  
     assert_not_equal(this, that)
   end
end

class ConsoleReporterTest < Test::Unit::TestCase
  
  def setup
    @output = StringIO.new
    @renderer = IndentityRenderer.new
    @reporter = PBar::ConsoleReporter.new(@renderer, @output)
    backspace = PBar::ConsoleReporter::BACKSPACE
    blank = PBar::ConsoleReporter::BLANK
    @status = "abc"
    @erasingString = "#{backspace * @status.length}#{blank * @status.length}#{backspace * @status.length}"
  end
  
  def test_when_print_is_called_once_then_one_line_is_printed    
    @reporter.print(@status)
    
    assert_equal(@status, @output.string)
  end
  
  def test_when_print_is_called_twice_with_a_line_then_two_lines_are_printed_and_the_first_one_gets_erased
    @reporter.print(@status)
    @reporter.print(@status)
    
    assert_equal(@status + @erasingString + @status, @output.string)
  end
  
  def test_when_several_lines_are_printed_then_erasing_string_gets_printed_in_between_them
    @reporter.print(@status)
    @reporter.print(@status)
    @reporter.print(@status)
    
    assert_equal(@status + @erasingString + @status + @erasingString + @status, @output.string)
  end

  def test_when_clearCurrentLine_is_called_then_erases_the_last_printed_status
    @reporter.print(@status)
    @reporter.clearCurrentLine
    
    assert_equal(@status + @erasingString, @output.string)
  end
  
  def test_when_clearCurrentLine_is_called_and_there_is_no_current_printed_status_then_nothing_is_erased
    @reporter.clearCurrentLine
    
    assert_equal("", @output.string)
  end
end

class ConsoleStatusRendererTest < Test::Unit::TestCase
  
  DONE_PERCENT = 50
  TODO_PERCENT = 50
  SPEED = 30
  UNIT_NAME = "Parrots"
  
  def setup
    @status = PBar::Status.new(:donePercent => DONE_PERCENT, :todoPercent => TODO_PERCENT, :speed => SPEED, :unitName => UNIT_NAME)
    @renderer = PBar::ConsoleStatusRenderer.new
  end
  
  def test_when_render_is_called_then_status_is_rendered
    doneSymbol = PBar::ConsoleStatusRenderer::DEFAULT_SYMBOLS[:done]
    todoSymbol = PBar::ConsoleStatusRenderer::DEFAULT_SYMBOLS[:todo]
      
    assert_equal("[#{doneSymbol * DONE_PERCENT}#{todoSymbol * TODO_PERCENT}] #{SPEED}.00 #{UNIT_NAME}/s", @renderer.render(@status))
  end
  
  def test_when_alternative_done_and_todo_symbols_are_provided_then_they_are_used_when_printing_statuses
    @renderer.useSymbols(:done => '+', :todo => '-')

    assert_equal("[#{'+' * DONE_PERCENT}#{'-' * TODO_PERCENT}] #{SPEED}.00 #{UNIT_NAME}/s", @renderer.render(@status))
  end
end