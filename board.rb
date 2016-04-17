require 'set'

class Board
  attr_reader :fields

  def initialize(grid_size, num_bombs)
    @grid_size, @num_bombs = grid_size, num_bombs
    @fields = initialize_fields
    @directions = [-1,0,1].permutation(2).to_a + [[1,1], [-1,-1]]
    set_bombs
    set_numbers
  end

  def get_field_in_grid(coordinates)
    coordinates = coordinates.split('-').map {|c| c.to_i} if coordinates.is_a?(String)
    row, column = coordinates
    field = get_row(row).select {|f| f.column == column}
    field.empty? ? nil : field.first
  end

  def covered_fields
    @fields.select {|f| f.covered}
  end


  def num_of_covered_fields
    covered_fields.length
  end

  def uncover_surrounding_fields(field)
    fields_to_uncover = fields_to_uncover(field, Set.new().add(field))
    fields_to_uncover.to_a.each { |f| f.covered = false }.map { |f| "#{f.row}-#{f.column}" }
  end

  def fields_to_uncover(field, collection)
    collected = collect_surrounding_fields(field)

    surrounding_empty, surrounding_number = collected[:empty], collected[:number]
    surrounding = surrounding_empty + surrounding_number

    unchecked_surrounding = surrounding - collection.to_a
    unchecked_empty = surrounding_empty - collection.to_a

    collection += surrounding
    return collection if unchecked_surrounding.empty?

    unchecked_empty.each { |f| collection += fields_to_uncover(f, collection) unless f.is_uncovered? }
    collection
  end

  def position_of_covered
    result = {in_the_middle: [], on_the_edge: {}}
    covered_fields.each do |field|
      surrounding = collect_surrounding_fields(field)
      result[:in_the_middle] << field if surrounding[:uncovered][:fields].length == 0
      if surrounding[:uncovered][:fields].length > 0
        num_uncovered = surrounding[:uncovered][:fields].length.to_s
        sum_nums = surrounding[:uncovered][:sum_nums]
        result[:on_the_edge][num_uncovered] ||= []
        result[:on_the_edge][num_uncovered] << {field: field, sum: sum_nums}
      end
    end
    result
  end

  def rows_to_s
    str = "\t|#{(0...@grid_size).to_a.join("\t")}\n"
    str += "\t|\n"
    @grid_size.times do |row_i|
      str += "#{row_i}\t|"
      get_row(row_i).each do |field|
        str +=  if field.covered
                  "X\t"
                else
                  case field.content
                    when 'bomb'
                      "M\t"
                    when 'number'
                      "#{field.touching_bombs}\t"
                    else
                      ".\t"

                  end
                end
      end
      str +="\n"
    end
    str
  end

  private

  def initialize_fields
    fields = []
    @grid_size.times do |i|
      @grid_size.times do |j|
        fields << Field.new(i,j)
      end
    end
    fields
  end

  def set_bombs
    @num_bombs.times do
      field = empty_field
      field.content = 'bomb'
    end
  end

  def set_numbers
    @fields.each do |field|
      next if field.has_bomb?
      calculate_touching(field)
    end
  end

  def calculate_touching(field)
    surrounding = collect_surrounding_fields(field)
    num_bomb_field = surrounding[:bomb].length
    field.set_touching_number(num_bomb_field) if num_bomb_field > 0
  end

  def collect_surrounding_fields(field)
    result = {
        bomb: [], empty: [], number: [],
        covered: {sum_nums: 0, fields: []}, uncovered: {sum_nums: 0, fields: []}
    }
    @directions.each do |row, column|
      f = get_field_in_grid([field.row+row, field.column+column])
      next if f.nil?
      result[f.content.to_sym] << f if f.has_content?
      result[:empty] << f unless f.has_content?
      key = f.covered ? :covered : :uncovered
      result[key][:fields] << f
      result[key][:sum_nums] += f.touching_bombs
    end
    result
  end

  def get_row(num)
    @fields.select {|f| f.row == num}.sort_by {|f| f.column}
  end

  def empty_field
    field = @fields.sample
    empty_field if field.has_content?
    field
  end
end