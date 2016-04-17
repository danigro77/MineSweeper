# =============================
#       MINE SWEEPER
# =============================
# Daniela Grossmann
# April, 2016

require './board.rb'
require './field.rb'
require './robot.rb'

# -----------------------------
#       Helper methods
# -----------------------------
def user_messages
  {
      set_player: "Do you want to play, or should a robot? [y,n]",
      welcome: "Welcome to MINE SWEEPER!",
      robot_game: "MINE SWEEPER SOLVER",
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
      yes_no_warn: "Only 'y' and 'n' are allowed as input",
      statistics: "Won games: %s \nLost games: %s",
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

def draw_board
  if human_player?
    msg_2spaces(:single_line)
    puts @board.rows_to_s
  else
    puts '.'
  end
end

def msg_2spaces(type)
  puts
  puts user_messages[type]
  puts
end

def msg_1space(type)
  puts user_messages[type]
  puts
end

def start_message(type)
  puts
  puts user_messages[:double_line]
  puts user_messages[type]
  puts user_messages[:double_line]
  puts
end

def show_statisics
  puts
  puts user_messages[:double_line]
  puts user_messages[:statistics] % [@wins, @losts]
  puts user_messages[:double_line]
  puts
end

def yes_no_input
  user_input = gets.chomp
  if user_input.downcase == 'y'
    true
  elsif user_input.downcase == 'n'
    false
  else
    msg_1space(:yes_no_warn)
    yield
  end
end

# -----------------------------
#       Game methods
# -----------------------------

def play_game
  set_variables

# Play the game
  until @game_end
    draw_board
    uncover_field
    @game_end = @lost || game_won?
  end

  msg_2spaces(:double_line)

  if @lost
    puts user_messages[:lost_game]
    @losts +=1
  else
    puts user_messages[:won_game]
    @wins += 1
  end

  draw_board

  if new_game?
    play_game
  else
    show_statisics
    msg_1space(:bye)
  end
end

def uncover_field
  field = @board.get_field_in_grid(human_player? ? uncover_dialog : robot_field_pick)
  if field
    field.uncover
    @lost = field.has_bomb?
    unless field.has_content?
      @uncovered_fields += @board.uncover_surrounding_fields(field)
      @robot.possible_moves -= @uncovered_fields unless human_player?
    end
  end
end

def robot_field_pick
  if @robot.possible_moves.length == @grid_size
    @robot.possible_moves.shuffle.pop
  else
    @robot.choose_field(@board)
  end
end

def uncover_dialog
  next_field = nil
  until next_field
    msg_2spaces(:uncover)
    input_indexes = gets.chomp.split('-')
    if input_indexes.length < 2
      msg_1space(:uncover_warn1)
    elsif input_indexes.length > 2
      msg_1space(:uncover_warn2)
    else
      if @uncovered_fields.include? input_indexes
        msg_1space(:uncover_warn3)
      elsif valid_indexes?(input_indexes)
        next_field = input_indexes.map {|i| i.to_i }
        @uncovered_fields << input_indexes
      else
        msg_1space(:uncover_warn4)
      end
    end
  end
  next_field
end

def set_player
  msg_2spaces(:set_player)
  human = yes_no_input { set_player }

  @player = human ? :human : :robot
end

def set_grid
  until @grid_size
    puts user_messages[:grid_size]
    size_input = gets.chomp
    if no_integer?(size_input)
      msg_1space(:grid_warn1)
    elsif size_input.to_i <= 1
      msg_1space(:grid_warn2)
    elsif size_input.to_i > 50
      msg_1space(:grid_warn3)
    else
      @grid_size = size_input.to_i
    end
  end
end

def set_bombs
  until @num_bombs
    puts user_messages[:num_bombs]
    size_input = gets.chomp
    if no_integer?(size_input)
      msg_1space(:bomb_warn1)
    elsif size_input.to_i < 1
      msg_1space(:bomb_warn2)
    elsif size_input.to_i > @grid_size**2
      msg_1space(:bomb_warn3)
    else
      @num_bombs = size_input.to_i
    end
  end
end

def set_variables
  @board = Board.new(@grid_size, @num_bombs)
  @game_end = false
  @uncovered_fields = []
  @lost = false
end

def new_game?
  if human_player?
    puts user_messages[:new_game]
    yes_no_input { new_game? }
  else
    @robot.num_of_turns -= 1
    @robot.num_of_turns > 0
  end
end

def game_won?
  @board.num_of_covered_fields == @num_bombs
end

def human_player?
  @player == :human
end

# -----------------------------
#       The Game
# -----------------------------

#   Initializing variables
def game
  set_player

  if human_player?
    start_message(:welcome)

    set_grid
    puts
    set_bombs

  else #non-human
    start_message(:robot_game)
    @robot = Robot.new()
    @grid_size = @robot.grid_size
    @num_bombs = @robot.num_bombs
  end

#   Initialize the game
  play_game
end

@wins = 0
@losts = 0

game
