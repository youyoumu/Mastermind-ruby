class Mastermind
  attr_accessor :the_code

  def initialize
    @the_code = []
    6.times do
      @the_code.push(Array(1..6).sample)
    end
  end

end

class CodeBreaker

end

computer = Mastermind.new
p computer.the_code
