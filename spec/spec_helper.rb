require_relative '../board'
require_relative '../field'
require_relative '../robot'

def selected_fields(fields, for_type, search_term)
  case for_type
    when :for_content
      fields.select {|f| f.content == search_term }
    when :for_cover
      fields.select {|f| f.covered == (search_term == 'covered')}
  end
end

def collect_surrounding_fields(board, field)
  result = []
  Board::DIRECTIONS.each do |row, column|
    f = get_field_in_grid(board, field.row+row, field.column+column)
    next if f.nil?
    result << f
  end
  result
end

def get_field_in_grid(board, row, column)
  board.fields.select {|f| f.row == row}
      .sort_by {|f| f.column}
      .select {|f| f.column == column}
      .first
end
