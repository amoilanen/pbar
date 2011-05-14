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

class StatusTest < Test::Unit::TestCase

   def test_when_donePercent_todoPercent_timeElapsed_are_less_than_zero_or_nil_then_exception_is_raised
     assert_raise(RuntimeError) do 
       PBar::Status.new(:donePercent => -10, :todoPercent => 110, :timeElapsed => 10)
     end
     assert_raise(RuntimeError) do 
       PBar::Status.new(:todoPercent => 50, :timeElapsed => 10)
     end
     assert_raise(RuntimeError) do 
       PBar::Status.new(:donePercent => 110, :todoPercent => -10, :timeElapsed => 10)
     end
     assert_raise(RuntimeError) do 
       PBar::Status.new(:donePercent => 50, :timeElapsed => 10)
     end
     assert_raise(RuntimeError) do 
       PBar::Status.new(:donePercent => 10, :todoPercent => 90, :timeElapsed => -10)
     end
     assert_raise(RuntimeError) do 
       PBar::Status.new(:donePercent => 10, :todoPercent => 90)
     end
   end

   def test_when_donePercent_todoPercent_timeElapsed_are_zero_no_exception_is_raised
     PBar::Status.new(:donePercent => 0, :todoPercent => 100, :timeElapsed => 10)
     PBar::Status.new(:donePercent => 100, :todoPercent => 0, :timeElapsed => 10)
     PBar::Status.new(:donePercent => 50, :todoPercent => 50, :timeElapsed => 0)
   end
   
   def test_when_other_status_has_same_fields_then_statuses_are_equal
     that = PBar::Status.new(:donePercent => 30, :todoPercent => 40, :timeElapsed => 10)
     this = PBar::Status.new(:donePercent => 30, :todoPercent => 40, :timeElapsed => 10)

     assert_equal(this, that)
   end

   def test_when_other_status_has_different_fields_then_statuses_are_not_equal
     this = PBar::Status.new(:donePercent => 30, :todoPercent => 40, :timeElapsed => 10)
     that = PBar::Status.new(:donePercent => 30, :todoPercent => 20, :timeElapsed => 10)
  
     assert_not_equal(this, that)
   end
   
   def test_when_speed_is_computed_with_timeElapsed_negative_or_zero_or_nil_then_exception_is_raised
     assert_raise(RuntimeError) do
       PBar::Status.new(:donePercent => 30, :todoPercent => 40, :timeElapsed => -10).speed
     end
     assert_raise(RuntimeError) do
       PBar::Status.new(:donePercent => 30, :todoPercent => 40, :timeElapsed => 0).speed
     end
     assert_raise(RuntimeError) do
       PBar::Status.new(:donePercent => 30, :todoPercent => 40).speed
     end
   end
   
   def test_when_speed_is_computed_with_unitsPerPercent_negative_or_zero_or_nil_then_exception_is_raised
     assert_raise(RuntimeError) do
       PBar::Status.new(:donePercent => 30, :todoPercent => 40, :timeElapsed => 10).speed(-10)
     end
     assert_raise(RuntimeError) do
       PBar::Status.new(:donePercent => 30, :todoPercent => 40, :timeElapsed => 10).speed(0)
     end
     assert_raise(RuntimeError) do
       PBar::Status.new(:donePercent => 30, :todoPercent => 40, :timeElapsed => 10).speed(nil)
     end
   end
   
   def test_when_donePecent_unitsPerPercent_and_timeElapsed_are_specified_then_they_are_used_to_compute_speed
     assert_equal(2.0, PBar::Status.new(:donePercent => 1, :todoPercent => 99, :timeElapsed => 5).speed(10))
     assert_equal(4.0, PBar::Status.new(:donePercent => 1, :todoPercent => 99, :timeElapsed => 5).speed(20))
     assert_equal(0.5, PBar::Status.new(:donePercent => 1, :todoPercent => 99, :timeElapsed => 20).speed(10))
     assert_equal(100.0, PBar::Status.new(:donePercent => 50, :todoPercent => 50, :timeElapsed => 5).speed(10))
   end
   
   def test_when_speed_is_computed_and_unitsPerPercent_is_not_specified_then_one_is_used_be_default
     assert_equal(0.2, PBar::Status.new(:donePercent => 1, :todoPercent => 99, :timeElapsed => 5).speed)
   end
end