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

    MAX_PERCENTS = 100
    
    attr_reader :listeners
    
    def initialize(params)
      @total = params[:total]
      raise if @total <= 0
      @timer = params[:timer]

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
      Status.new(:donePercent => donePercent, :todoPercent => todoPercent, :timeElapsed => @timer.elapsed)
    end
  end
  
  class Status
    
    include Comparable

    attr_reader :donePercent, :todoPercent, :timeElapsed
     
    def initialize(params)
      @donePercent = checkNotNegative(params[:donePercent])
      @todoPercent = checkNotNegative(params[:todoPercent])
      @timeElapsed = checkNotNegative(params[:timeElapsed])
    end
    
    def speed(unitsPerPercent = 1)
      unitsPerPercent = checkPositive(unitsPerPercent)
      timeElapsed = checkPositive(@timeElapsed)
      donePercent.to_f * unitsPerPercent.to_f / timeElapsed.to_f
    end
    
    def comparable_fields
      [donePercent, todoPercent, timeElapsed]
    end
 
    def <=>(other)
      self.comparable_fields <=> other.comparable_fields
    end
    
    private
    
    def checkNotNegative(value)
      checkThat(value) {|x| x >= 0}
    end
    
    def checkPositive(value)
      checkThat(value) {|x| x > 0}
    end
    
    def checkThat(value)
      raise if value.nil? || !yield(value)
      value
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
      @showSpeed = false
    end
    
    def render(status)
      rendered = "[" + (symbols[:done] * status.donePercent) + (symbols[:todo] * status.todoPercent)  + "]"
      if @showSpeed 
        rendered + " " + ('%.2f' % status.speed(@unitsPerPercent)) + " " + @unitName + "/s"
      else
        rendered
      end
    end

    def showSpeed(unitName, unitsPerPercent)
      raise if unitName.nil? || unitsPerPercent.nil?
      @showSpeed = true
      @unitName = unitName
      @unitsPerPercent = unitsPerPercent
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