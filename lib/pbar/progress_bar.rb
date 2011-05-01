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
  
    UNKNOWN_SPEED = "unknown speed"
    MAX_PERCENTS = 100
    
    attr_reader :listeners
    
    def initialize(params)
      @total = params[:total]
      @unitsPerItem = params[:unitsPerItem]
      @unitName = params[:unitName]
      @timer = params[:timer]
      raise if @total <= 0 || @unitsPerItem <= 0
      @done = 0
      @listeners = []
    end
  
    def start
      @timer.start
    end
  
    def increment(done = 1)
      raise if done <= 0
      if @done + done <= @total
        @done = @done + done
      end
      listeners.each {|listener| listener.onStatus(getStatus)}
    end

    def percentDone
      @done.to_f / @total.to_f * MAX_PERCENTS.to_f
    end

    def getStatus
      donePercent = percentDone.ceil
      todoPercent = MAX_PERCENTS - donePercent
    
      if @timer.elapsed > 0
        speed =  @done.to_f * @unitsPerItem.to_f / @timer.elapsed.to_f
      else
        speed = UNKNOWN_SPEED
      end
      Status.new(:donePercent => donePercent, :todoPercent => todoPercent, :speed => speed, :unitName => @unitName)
    end
  end

  class Status
     
    include Comparable

    attr_reader :donePercent, :todoPercent, :speed, :unitName
     
    def initialize(params)
      raise if params[:donePercent] < 0 || params[:todoPercent] < 0
      @donePercent = params[:donePercent]
      @todoPercent = params[:todoPercent]
      @unitName = params[:unitName].nil? ? "" : params[:unitName]
      @speed = params[:speed]
    end

    def comparable_fields
      [donePercent, todoPercent, speed, unitName]
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

  class ConsoleStatusRenderer
    
    DEFAULT_SYMBOLS = {:done => "#", :todo => " "}
    
    attr_reader :symbols
      
    def initialize
      @symbols = DEFAULT_SYMBOLS
    end
    
    def render(status)
      rendered = "[" + (symbols[:done] * status.donePercent) + (symbols[:todo] * status.todoPercent)  + "]"
      rendered = rendered + " " + ('%.2f' % status.speed) + " " + status.unitName + "/s"
    end
    
    def useSymbols(customSymbols)
      @symbols = @symbols.merge(customSymbols)
    end
  end
  
  class ConsoleReporter
    
    BACKSPACE = "\b"
    BLANK = " "
    
    def initialize(statusRenderer, output=STDOUT)
      @statusRenderer = statusRenderer 
      @output = output
      @symbolsToErase = 0
    end

    def onStatus(status)
      print(status)
    end
    
    def print(status)
      clearCurrentLine
      status = @statusRenderer.render(status)
      printStatusString(status)
    end
    
    def clearCurrentLine
      returnCursorToStringStart
      erasePreviousStatus
      returnCursorToStringStart
      @output.flush
    end
    
    private
        
    def printStatusString(status)
      @output.print(status)
      @output.flush
      @symbolsToErase = status.length
    end
    
    def returnCursorToStringStart
      @output.print(BACKSPACE * @symbolsToErase)
    end
    
    def erasePreviousStatus
      @output.print(BLANK * @symbolsToErase)
    end
  end
end

#TODO: This example should be somewhere in the documentation provided with the gem
=begin
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
=end