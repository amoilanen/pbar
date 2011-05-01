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

module PBar

  class Progress
  
    def initialize(params)
      @total = params[:total]
      @unitsPerItem = params[:unitsPerItem]
      @unitName = params[:unitName]
      @timer = params[:timer]
      raise if @total <=0 || @unitsPerItem <= 0
      @done = 0
      @progressListeners = []
    end
  
    def addProgressListener(listener)
      @progressListeners << listener
    end
  
    def start
      @timer.start
    end
  
    def increment(done=1)
      if @done + done <= @total
        @done = @done + done
      end
      @progress
    end

    def percentDone
      ((1.0 * @done) / (1.0 * @total)) * 100
    end

    def getStatus
      donePercent = percentDone.ceil
      todoPercent = 100 - donePercent
    
      if @timer.elapsed > 0
        speed =  (1.0 * @done * @unitsPerItem) / @timer.elapsed
      else
        #TODO: Extract this as a constant and update the corresponding test
        speed = "n/a"
      end
      Status.new(:donePercent => donePercent, :todoPercent => todoPercent, :speed => speed)
    end
  end

  class Status
     
    include Comparable

    attr_reader :donePercent, :todoPercent, :speed
     
    def initialize(numbers)
      raise if numbers[:donePercent] < 0 || numbers[:todoPercent] < 0
      @donePercent = numbers[:donePercent]
      @todoPercent = numbers[:todoPercent]
      @speed = numbers[:speed]
    end

    def comparable_fields
      [donePercent, todoPercent, speed]
    end
 
    def <=>(other)
      self.comparable_fields <=> other.comparable_fields
    end
  end

  class Timer 

    def start
      @startTime = Time.now
    end

    def elapsed
      Time.now - @startTime
    end
  end

  class ConsoleReporter

    #TODO: Make these constants parameterizable
    @@doneSymbol = "#"
    @@todoSymbol = " "
    @@backspaceSymbol = "\b"
    @@blankSymbol = " "

    def initialize
      @symbolsToErase = 0
    end

    def report(status)
      printProgress(status)
    end

    def clearCurrentLine
      $stdout.print(@@backspaceSymbol * @symbolsToErase)
      $stdout.print(@@blankSymbol * @symbolsToErase)
      $stdout.print(@@backspaceSymbol * @symbolsToErase)
      $stdout.flush
    end

    private

    def print(status)
      clearCurrentLine
      toPrint = "[" + (@@doneSymbol * status.donePercent) + (@@todoSymbol * status.todoPercent)  + "]"
      toPrint = toPrint + " " + ('%.2f' % status.speed) + " " + @unitName + "/s"
      @symbolsToErase = toPrint.length
      $stdout.print(toPrint)
      $stdout.flush
    end
  end
end

=begin
items = 10
bar = Progress::Bar.new(:total => items, :unitsPerItem => 1024, :unitName => "KBit", :timer => Progress::Timer.new)
bar.start
sleep 1

items.times do |i|
  bar.increment
  bar.reportProgress
  sleep 1
end
bar.clearCurrentLine
=end