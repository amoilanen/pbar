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

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'pbar/progress_bar'

class TotalProgressReporter
  
  attr_reader :donePercent

  def onStatus(status)
    @donePercent = status.donePercent
  end
  
  def onFinished
    puts "Done percent=#{donePercent}"
  end
end

def doSomeWork
  sleep 1
end

totalWorkUnits = 3

progress = PBar::Progress.progress(totalWorkUnits) do
  listeners << TotalProgressReporter.new
end

progress.start
doSomeWork

totalWorkUnits.times do
  doSomeWork
  progress.increment
end