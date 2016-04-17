class Robot
  attr_reader :num_bombs, :grid_size
  attr_accessor :num_of_turns, :possible_moves

  DEFAULT = {
      grid_size: 10,
      num_bombs: 10,
      num_of_turns: 100000
  }

  def initialize()
    @grid_size = DEFAULT[:grid_size]
    @num_bombs = DEFAULT[:num_bombs]
    @num_of_turns = DEFAULT[:num_of_turns]
    @possible_moves = calculate_moves
  end

  def choose_field(board)
    # Strategy for the Robot's picks:
    # First uncover all fields with no uncovered neighbours
    # Then uncover the ones with the smallest sum of surrounding numbers
    covered_fields = board.position_of_covered
    field = if covered_fields[:in_the_middle].length > 0
              covered_fields[:in_the_middle].sample
            else
              fields = covered_fields[:on_the_edge]
              keys = fields.keys.map(&:to_i).sort
              fields[keys.last.to_s].sort_by { |f| f[:sum]}.first[:field]
            end
    next_field = [field.row, field.column]
    @possible_moves -= [next_field]
    next_field
  end

  def reset_moves
    @possible_moves = calculate_moves
  end

  private

  def calculate_moves
    moves = []
    @grid_size.times { |i| @grid_size.times { |j| moves << [i,j] } }
    moves
  end
end