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
      stats_win_lost: "Won games: %s \nLost games: %s",
      stats_total: "Total games played: %s",
      bye: "BYE! See you soon!",
      double_line: "============================",
      single_line: "----------------------------"
  }
end

def valid_indexes?(input_indexes, grid_size)
  valid = true
  input_indexes.each do |index|
    valid = false if no_integer?(index) || index.to_i > grid_size
  end
  valid
end

def no_integer?(input)
  input.to_i.to_s != input
end

def draw_board(board)
  if human_player?
    msg_2spaces(:single_line)
    puts board.rows_to_s
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
  puts user_messages[:stats_win_lost] % [@wins, @losts]
  puts user_messages[:singe_line]
  puts user_messages[:stats_total] % [@wins+@losts]
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