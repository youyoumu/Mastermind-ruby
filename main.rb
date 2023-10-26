module OutputText
  def input_invalid
    puts 'Input invalid! Try again: '
  end

  def attempt_count(count)
    puts "Attempt: #{count}"
  end
end

module CheckInput
  def input_valid?(combination)
    return false unless combination.length == 4

    combination.each do |number|
      return false unless Array(1..6).include?(number)
    end
    true
  end
end

class Mastermind
  include CheckInput
  include OutputText
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

  def set_new_code
    input = gets.chomp.split('')
    input = input.map do |number|
      number.to_i
    end
    if input_valid?(input)
      @the_code = input
    else
      input_invalid
      set_new_code
    end
  end

  private

  def count_correct_number(combination)
    subtracted_array = subtract_with_duplicates(@the_code, get_correct_position_array(combination))
    combination.each do |number|
      @correct_number += 1 if subtracted_array.include?(number)
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
      correct_position_array.push(combination[i]) if @the_code[i] == combination[i]
      i += 1
    end
    correct_position_array
  end

  def subtract_with_duplicates(array1, array2)
    result = array1.dup
    array2.each do |element|
      index = result.index(element)
      result.delete_at(index) if index
    end
    result
  end

  def announce_hint
    correct_number.times do
      print '○'
    end
    correct_position.times do
      print '●'
    end
    puts ''
  end

  def reset_counter
    @correct_number = 0
    @correct_position = 0
  end
end

class CodeBreaker
  include OutputText
  include CheckInput
  attr_accessor :combination, :attempt, :computer_guess

  def initialize
    @attempt = 0
    @computer_guess = []
    @correct_guess = []
  end

  def guess(combination)
    @combination = combination.split('')
    @combination = @combination.map do |string|
      string.to_i
    end
    return if input_valid?(@combination)

    input_invalid
    guess(gets.chomp)
  end

  def guess_as_computer
    guess_first_time if @computer_guess.empty?
    p @computer_guess
    sleep(1)
    @computer_guess
  end

  def guess_first_time
    4.times do
      @computer_guess.push(Array(1..6).sample)
    end
  end

  def set_better_guess(computer_guess, the_code)
    element_counts = Hash.new(0)
    the_code.each do |element|
      element_counts[element] += 1
    end

    computer_guess.each do |number|
      guess_element_counts = Hash.new(0)
      @correct_guess.each do |element|
        guess_element_counts[element] += 1
      end
      next unless the_code.include?(number)

      @correct_guess.push(number) if guess_element_counts[number] < element_counts[number]
    end

    if @correct_guess.empty?
      @computer_guess.clear
      guess_first_time
      return
    end

    @computer_guess = @correct_guess.dup.shuffle

    return unless @computer_guess.length != 4

    until @computer_guess.length == 4
      @computer_guess.shuffle!
      @computer_guess.push(Array(1..6).sample)
    end
  end
end

class Game
  include OutputText
  attr_accessor :mastermind

  def initialize
    @mastermind = Mastermind.new
    @codebreaker = CodeBreaker.new
    @player_win = false
    @computer_win = false
  end

  def play_as_codebreaker
    @codebreaker.attempt += 1
    attempt_count(@codebreaker.attempt)
    @codebreaker.guess(gets.chomp)
    @mastermind.check_guess(@codebreaker.combination)
    play_as_codebreaker until @mastermind.correct_position == 4 || @codebreaker.attempt == 10
    @player_win = true if @mastermind.correct_position == 4
  end

  def play_as_mastermind
    @codebreaker.attempt += 1
    attempt_count(@codebreaker.attempt)
    @mastermind.check_guess(@codebreaker.guess_as_computer)
    @codebreaker.set_better_guess(@codebreaker.computer_guess, @mastermind.the_code)
    play_as_mastermind until @mastermind.correct_position == 4 || @codebreaker.attempt == 10
    @computer_win = true if @mastermind.correct_position == 4
  end

  def announce_player_win
    if @player_win
      puts 'You Win!'
    else
      puts 'You Lose!'
    end
  end

  def announce_computer_win
    if @computer_win
      puts 'Computer Win!'
    else
      puts 'Computer Lose!'
    end
  end
end

game = Game.new

puts "Do you want to play as 'Mastermind' or 'Codebreaker'?"
select = gets.chomp.downcase
if select == 'mastermind'
  print 'Set the Secred Code: '
  game.mastermind.set_new_code
  game.play_as_mastermind
  game.announce_computer_win
elsif select == 'codebreaker'
  game.play_as_codebreaker
  game.announce_player_win
else
  puts 'Input Invalid!'
end
