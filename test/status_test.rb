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