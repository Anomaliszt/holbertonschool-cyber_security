#!/usr/bin/env ruby

class HelloWorld
    def initialize(message = "Hello, World!")
        @message = message
    end
    
    def print_hello
        puts @message
    end
end
