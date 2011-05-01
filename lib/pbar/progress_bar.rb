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

  UNKNOWN_SPEED = "unknown speed"
  MAX_PERCENTS = 100
  
  class Progress
  
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
        speed = PBar::UNKNOWN_SPEED
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

  class ConsoleReporter

    #TODO: Make these constants parameterizable
    @@doneSymbol = "#"
    @@todoSymbol = " "
    @@backspaceSymbol = "\b"
    @@blankSymbol = " "

    def initialize()
      @symbolsToErase = 0
    end

    def onStatus(status)
      print(status)
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
      toPrint = toPrint + " " + ('%.2f' % status.speed) + " " + status.unitName + "/s"
      @symbolsToErase = toPrint.length
      $stdout.print(toPrint)
      $stdout.flush
    end
  end
end

#TODO: This example should be somewhere in the documentation provided with the gem
=begin
items = 10

bar = PBar::Progress.new(:total => items, :unitsPerItem => 1024, :unitName => "KBit", :timer => PBar::Timer.new)
consoleReporter = PBar::ConsoleReporter.new
bar.listeners << consoleReporter

bar.start
sleep 1

items.times do |i|
  bar.increment
  sleep 1
end
consoleReporter.clearCurrentLine
=end