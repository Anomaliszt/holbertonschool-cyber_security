#!/usr/bin/env ruby

class CaesarCipher
    def initialize(shift)
        @shift = shift
    end 

    def encrypt(message)
        cipher(message, @shift)
    end

    def decrypt(message)
        cipher(message, -@shift)
    end

    private

    def cipher(message, shift)
        result = ""

        message.each_char do |c|
        if c >= 'A' && c <= 'Z'
            result << ((c.ord - 'A'.ord + shift) % 26 + 'A'.ord).chr
        elsif c >= 'a' && c <= 'z'
            result << ((c.ord - 'a'.ord + shift) % 26 + 'a'.ord).chr
        else
            result << c
        end
        end

        result
    end
end
