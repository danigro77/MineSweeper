# =============================
#       MINE SWEEPER
# =============================
# Daniela Grossmann
# April, 2016

require './board.rb'
require './field.rb'
require './robot.rb'
require './helper.rb'

# -----------------------------
#       Game methods
# -----------------------------

def play_game
  set_variables

  puts "Turns left: #{@robot.num_of_turns}" unless human_player?

# Play the game
  until @game_end
    draw_board(@board)
    uncover_field
    @game_end = @lost || game_won?
  end

  # msg_2spaces(:double_line)

  if @lost
    puts user_messages[:lost_game]
    @losts +=1
  else
    puts user_messages[:won_game]
    @wins += 1
  end

  draw_board(@board)

  play_again?
end

def uncover_field
  coordiantes =  human_player? ? uncover_dialog : robot_field_pick
  row, column = coordiantes[0], coordiantes[1]

  field = @board.get_field_in_grid(row, column)
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
    f = @robot.possible_moves.shuffle.pop
  else
    f = @robot.choose_field(@board)
  end
  f
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
      if @uncovered_fields.include? input_indexes.map {|i| i.to_i }
        msg_1space(:uncover_warn3)
      elsif valid_indexes?(input_indexes, @grid_size)
        next_field = input_indexes.map {|i| i.to_i }
        @uncovered_fields << next_field
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

def play_again?
  if human_player?
    puts user_messages[:new_game]
    @play_again = yes_no_input { new_game? }
  else
    @robot.num_of_turns -= 1
    @play_again = @robot.num_of_turns > 0
    @robot.reset_moves if @play_again
  end
  unless @play_again
    show_statisics
    msg_1space(:bye)
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
def new_game
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
  @play_again = true
end

@wins = 0
@losts = 0

new_game
play_game while @play_again
