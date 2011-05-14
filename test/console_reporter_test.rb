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

class IdentityRenderer
  
  def render(status)
    status
  end
end

class ConsoleReporterTest < Test::Unit::TestCase
  
  def setup
    @output = StringIO.new
    @renderer = IdentityRenderer.new
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