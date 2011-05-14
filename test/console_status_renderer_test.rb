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
require File.expand_path(File.dirname(__FILE__) + '/../lib/pbar/progress_bar.rb')
require 'test/unit'
require 'flexmock/test_unit'

class ConsoleStatusRendererTest < Test::Unit::TestCase
  
  DONE_PERCENT = 50
  TODO_PERCENT = 50
  SPEED = 30
  UNITS_PER_PERCENT = 20
  UNIT_NAME = "unit"
  OTHER_UNITS_PER_PERCENT = UNITS_PER_PERCENT + 1
  OTHER_UNIT_NAME = "other #{UNIT_NAME}"
  
  def setup
    @status = flexmock("status")
    @status.should_receive(:donePercent).and_return(DONE_PERCENT)
    @status.should_receive(:todoPercent).and_return(TODO_PERCENT)
    @status.should_receive(:speed).with(UNITS_PER_PERCENT).and_return(SPEED)
    
    @doneSymbol = PBar::ConsoleStatusRenderer::DEFAULT_SYMBOLS[:done]
    @todoSymbol = PBar::ConsoleStatusRenderer::DEFAULT_SYMBOLS[:todo]
    @renderer = PBar::ConsoleStatusRenderer.new
  end
  
  def test_when_render_is_called_then_status_is_rendered
    @renderer.showSpeed(UNIT_NAME, UNITS_PER_PERCENT)

    assert_equal("[#{@doneSymbol * DONE_PERCENT}#{@todoSymbol * TODO_PERCENT}] #{SPEED}.00 #{UNIT_NAME}/s", @renderer.render(@status))
  end
  
  def test_when_speed_showing_is_not_switched_on_then_it_is_not_shown
    assert_equal("[#{@doneSymbol * DONE_PERCENT}#{@todoSymbol * TODO_PERCENT}]", @renderer.render(@status))
  end
  
  def test_when_alternative_done_and_todo_symbols_are_provided_then_they_are_used_when_printing_statuses
    @renderer.useSymbols(:done => '+', :todo => '-')
    @renderer.showSpeed(UNIT_NAME, UNITS_PER_PERCENT)
    
    assert_equal("[#{'+' * DONE_PERCENT}#{'-' * TODO_PERCENT}] #{SPEED}.00 #{UNIT_NAME}/s", @renderer.render(@status))
  end
  
  def test_when_showSpeed_is_called_several_times_then_unitName_and_unitsPerPercent_are_taked_from_last_call    
    @renderer.showSpeed(OTHER_UNIT_NAME, OTHER_UNITS_PER_PERCENT)
    @renderer.showSpeed(UNIT_NAME, UNITS_PER_PERCENT)
    
    assert_equal("[#{@doneSymbol * DONE_PERCENT}#{@todoSymbol * TODO_PERCENT}] #{SPEED}.00 #{UNIT_NAME}/s", @renderer.render(@status))
  end
  
  def test_when_unitName_or_unitsPerPercent_are_nil_then_exception_is_raised
    assert_raise(RuntimeError) do 
        @renderer.showSpeed(UNIT_NAME, nil)
    end
    assert_raise(RuntimeError) do 
        @renderer.showSpeed(nil, UNITS_PER_PERCENT)
    end
  end  
end