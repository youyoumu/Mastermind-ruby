module OutputText
  def input_invalid
   puts "Input invalid! Try again: "
  end

  def attempt_count(count)
    puts "Attempt: #{count}"
  end
 end

class Mastermind
  attr_accessor :the_code, :correct_number, :correct_position

  def initialize
    @the_code = []
    @correct_number = 0
    @correct_position = 0
    4.times do
      @the_code.push(Array(1..6).sample)
    end
  end

  def check_guess(combination)
    count_correct_number(combination)
    count_correct_position(combination)
    announce_hint
    reset_counter unless @correct_position == 4
  end

  private

  def count_correct_number(combination)
    subtracted_array = subtract_with_duplicates(@the_code, get_correct_position_array(combination))
    combination.each do |number|
      @correct_number +=1 if subtracted_array.include?(number)
    end
  end

  def count_correct_position(combination)
    i = 0
    while i < 4
      if @the_code[i] == combination[i]
        @correct_position += 1
        @correct_number -= 1
      end
      i += 1
    end
  end

  def get_correct_position_array(combination)
    correct_position_array = []
    i = 0
    while i < 4
      if @the_code[i] == combination[i]
        correct_position_array.push(combination[i])
      end
      i += 1
    end
    correct_position_array
  end

  def subtract_with_duplicates(array1, array2)
    result = array1.dup
    array2.each do |element|
      index = result.index(element)
      if index
        result.delete_at(index)
      end
    end
    result
  end

  def announce_hint
    correct_number.times do
      print "○"
    end
    correct_position.times do
      print "●"
    end
    puts ""
  end

  def reset_counter
    @correct_number = 0
    @correct_position = 0
  end
end

class CodeBreaker
  include OutputText
  attr_accessor :combination, :attempt

  def initialize
    @attempt = 0
  end

  def guess(combination)
    @combination = combination.split("")
    @combination = @combination.map do |string|
      string.to_i
    end
    unless input_valid?(@combination)
      input_invalid
      guess(gets.chomp)
    end
  end

  private

  def input_valid?(combination)
    return false unless combination.length == 4
    combination.each do |number|
      return false unless Array(1..6).include?(number)
    end
    true
  end

end

class Game
  include OutputText
  attr_accessor :mastermind

  def initialize
    @mastermind = Mastermind.new
    @codebreaker = CodeBreaker.new
    @player_win = false
  end

  def play_as_codebreaker
    @codebreaker.attempt += 1
    attempt_count(@codebreaker.attempt)
    @codebreaker.guess(gets.chomp)
    @mastermind.check_guess(@codebreaker.combination)
    until @mastermind.correct_position == 4 || @codebreaker.attempt == 10
      play_as_codebreaker
    end
    @player_win = true if @mastermind.correct_position == 4
  end

  def announce_player_win
    if @player_win
      puts "You Win!"
    else
      puts "You Lose!"
    end
  end

end

game = Game.new
p game.mastermind.the_code
game.play_as_codebreaker
game.announce_player_win
