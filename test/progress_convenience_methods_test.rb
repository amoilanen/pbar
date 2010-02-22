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
require 'flexmock/test_unit'

class ProgressConvenienceMethodsTest < Test::Unit::TestCase
 
  def setup
    @total = 11
    @timer = PBar::Timer.new
    @reporter = flexmock("reporter")
  end

  def test_when_no_block_is_provided_then_default_progress_is_constructed
    @progress = PBar::Progress.progress(@total, @timer)
    
    assert_progress_constructed_with_a(PBar::ConsoleReporter)
  end
  
  def test_when_block_of_zero_arity_is_provided_then_progress_is_constructed
    @progress = PBar::Progress.progress(@total, @timer) do
      listeners << PBar::ConsoleReporter.new()
    end
    
    assert_progress_constructed_with_a(PBar::ConsoleReporter)
  end
  
  def test_when_block_of_arity_one_is_provided_then_progress_is_constructed
    @progress = PBar::Progress.progress(@total, @timer) do |p|
      p.listeners << @reporter
    end

    assert_progress_constructed
  end
  
  def test_when_block_of_large_arity_is_provided_then_progress_is_constructed
    @progress = PBar::Progress.progress(@total, @timer) do |p, q|
      p.listeners << @reporter
    end

    assert_progress_constructed
  end
  
  def assert_progress_constructed
    assert_equal(@total, @progress.total)
    assert_equal(@timer, @progress.timer)
    assert_equal([@reporter], @progress.listeners)
  end
  
  def assert_progress_constructed_with_a(reporterClass)
    assert_equal(@total, @progress.total)
    assert_equal(@timer, @progress.timer)
    assert_equal(1, @progress.listeners.size)
    assert_equal(reporterClass, @progress.listeners[0].class)
  end
end