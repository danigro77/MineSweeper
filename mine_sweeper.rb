# =============================
#       MINE SWEEPER
# =============================
# Daniela Grossmann
# April, 2016

require './board.rb'
require './field.rb'

# -----------------------------
#       Helper methods
# -----------------------------
def user_output
  {
      welcome: "Welcome to MINE SWEEPER!",
      grid_size: "How big should be your square grid? ",
      grid_warn1: "This needs to be an Integer.",
      grid_warn2: "Please pick a bigger grid.",
      grid_warn3: "Please pick a smaller grid.",
      num_bombs: "How many bombs do you like to defuse? ",
      bomb_warn1: "This needs to be an Integer.",
      bomb_warn2: "Please pick more bombs.",
      bomb_warn3: "Too many bombs for the grid.",
      uncover: "Uncover a field (row-column, like 0-1): ",
      uncover_warn1: "Please make sure your input is correct and the values are seperated with a dash.",
      uncover_warn2: "You gave too many values.",
      uncover_warn3: "This was already used.",
      uncover_warn4: "Only integers are allowed that are on the grid.",
      won_game: "Congratulations, you won!",
      lost_game: "Sorry, you lost!",
      new_game: "Do you want to play a new game? [y/n] ",
      new_game_warn: "Only 'y' and 'n' are allowed as input",
      bye: "BYE! See you soon!",
      double_line: "============================",
      single_line: "----------------------------"
  }
end

def valid_indexes?(input_indexes)
  valid = true
  input_indexes.each do |index|
    valid = false if no_integer?(index) || index.to_i > @grid_size
  end
  valid
end

def no_integer?(input)
  input.to_i.to_s != input
end

# -----------------------------
#       Game methods
# -----------------------------

def play_game
  @board = Board.new(@grid_size, @num_bombs)
  @game_end = false
  @uncovered_fields = []
  @lost = false

# Play the game
  until @game_end
    draw_board
    uncover_field
    @game_end = @lost || game_won?
  end

  draw_line(:double_line)

  if @lost
    puts user_output[:lost_game]
  else
    puts user_output[:won_game]
  end

  draw_board
  draw_line(:double_line)

  if new_game?
    play_game
  else
    puts
    puts user_output[:bye]
    puts
  end
end

def draw_board
  draw_line(:single_line)
  puts @board.rows_to_s
end

def draw_line(type)
  puts
  puts user_output[:double_line]
  puts
end

def uncover_field
  field = @board.get_field_in_grid(uncover_dialog)
  if field
    field.uncover
    @lost = field.has_bomb?
    unless field.has_content?
      @board.uncover_surrounding_fields(field)
    end
  end
end

def uncover_dialog
  next_field = nil
  until next_field
    puts
    puts user_output[:uncover]
    input_indexes = gets.chomp.split('-')
    if input_indexes.length < 2
      puts user_output[:uncover_warn1]
      puts
    elsif input_indexes.length > 2
      puts user_output[:uncover_warn2]
      puts
    else
      if @uncovered_fields.include? input_indexes
        puts user_output[:uncover_warn3]
        puts
      elsif valid_indexes?(input_indexes)
        next_field = input_indexes.map {|i| i.to_i }
        @uncovered_fields << input_indexes
      else
        puts user_output[:uncover_warn4]
        puts
      end
    end
  end
  next_field
end

def new_game?
  puts user_output[:new_game]
  user_input = gets.chomp

  if user_input.downcase == 'y'
    true
  elsif user_input.downcase == 'n'
    false
  else
    user_output[:new_game_warn]
    new_game?
  end
end

def game_won?
  # all bombs covered
  @board.num_of_covered_fields == @num_bombs
end


# -----------------------------
#       The Game
# -----------------------------

#   Initializing variables
puts
puts user_output[:double_line]
puts user_output[:welcome]
puts user_output[:double_line]
puts

until @grid_size
  puts user_output[:grid_size]
  size_input = gets.chomp
  if no_integer?(size_input)
    puts user_output[:grid_warn1]
    puts
  elsif size_input.to_i <= 1
    puts user_output[:grid_warn2]
    puts
  elsif size_input.to_i > 50
    puts user_output[:grid_warn3]
    puts
  else
    @grid_size = size_input.to_i
  end
end
puts
until @num_bombs
  puts user_output[:num_bombs]
  size_input = gets.chomp
  if no_integer?(size_input)
    puts user_output[:bomb_warn1]
    puts
  elsif size_input.to_i < 1
    puts user_output[:bomb_warn2]
    puts
  elsif size_input.to_i > @grid_size**2
    puts user_output[:bomb_warn3]
    puts
  else
    @num_bombs = size_input.to_i
  end
end

#   Initialize the game
play_game
