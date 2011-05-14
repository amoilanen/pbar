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