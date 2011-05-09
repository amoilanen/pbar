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

items = 10

bar = PBar::Progress.new(:total => items, :unitsPerItem => 1024, :unitName => "KBit", :timer => PBar::Timer.new)
renderer = PBar::ConsoleStatusRenderer.new
consoleReporter = PBar::ConsoleReporter.new(renderer)
bar.listeners << consoleReporter

bar.start
sleep 1

items.times do |i|
  bar.increment
  sleep 1
end
consoleReporter.clearCurrentLine