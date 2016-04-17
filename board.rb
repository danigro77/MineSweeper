require 'set'

class Board
  attr_reader :fields, :grid_size, :num_bombs

  DIRECTIONS = [[-1,-1], [-1,0], [-1,1], [0,1], [0,-1], [1,1], [1,0], [1,-1]]

  def initialize(grid_size, num_bombs)
    @grid_size, @num_bombs = grid_size, num_bombs
    @fields = initialize_fields
    set_bombs
    set_numbers
  end

  def get_field_in_grid(row, column)
    begin
      if valid_coordinates?(row, column)
        get_row(row).select {|f| f.column == column}.first
      else
        nil
      end
    rescue Exception => e
      puts e
    end
  end

  def covered_fields
    @fields.select {|f| f.covered}
  end

  def num_of_covered_fields
    covered_fields.length
  end

  def uncover_surrounding_fields(field)
    fields_to_uncover = fields_to_uncover(field, Set.new().add(field))
    fields_to_uncover.to_a.each { |f| f.covered = false }.map { |f| [f.row, f.column] }
  end

  def position_of_covered
    # seperates covered fields into two groups:
    # - ones that are in the middle of other covered fields
    # - and those that have one or more uncovered fields as neighbours
    result = {in_the_middle: [], on_the_edge: {}}
    covered_fields.each do |field|
      surrounding = collect_surrounding_fields(field, :for_cover)
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

  def bomb_fields
    @fields.select {|f| f.has_bomb? }
  end

  def set_bombs
    until @num_bombs == bomb_fields.length do
      field = get_empty_field
      field.content = 'bomb' unless field.nil?
    end
  end

  def set_numbers
    @fields.each do |field|
      next if field.has_bomb?
      calculate_touching(field)
    end
  end

  def calculate_touching(field)
    surrounding = collect_surrounding_fields(field, :for_content)
    num_bomb_field = surrounding[:bomb].length
    field.set_touching_number(num_bomb_field) if num_bomb_field > 0
  end

  def collect_surrounding_fields(field, purpose)
    # analyses and collect the fields on the board in seperate buckets
    result = case purpose
               when :for_content
                 { bomb: [], empty: [], number: [] }
               when :for_cover
                 { covered: {sum_nums: 0, fields: []},
                   uncovered: {sum_nums: 0, fields: []} }
             end
    DIRECTIONS.each do |row, column|
      f = get_field_in_grid(field.row+row, field.column+column)
      next if f.nil?
      result = create_content_hash(f, result) if purpose == :for_content
      result = create_cover_hash(f, result) if purpose == :for_cover
    end
    result
  end

  def create_content_hash(field, result)
    result[field.content.to_sym] << field if field.has_content?
    result[:empty] << field unless field.has_content?
    result
  end

  def create_cover_hash(field, result)
    key = field.covered ? :covered : :uncovered
    result[key][:fields] << field
    result[key][:sum_nums] += field.touching_bombs
    result
  end

  def get_row(num)
    # this one was sometimes failing after many runs
    @fields.select {|f| f.row == num}.sort_by {|f| f.column}
  end

  def get_empty_field
    field = @fields.sample
    field.has_content? ? nil : field
  end

  def fields_to_uncover(field, collection)
    # finds all fields that are empty, stops but includes it, when the field has a number
    return collection if field.nil?
    collected = collect_surrounding_fields(field, :for_content)

    surrounding_empty, surrounding_number = collected[:empty], collected[:number]
    surrounding = surrounding_empty + surrounding_number

    unchecked_surrounding = surrounding - collection.to_a
    unchecked_empty = surrounding_empty - collection.to_a

    collection += surrounding
    return collection if unchecked_surrounding.empty?

    unchecked_empty.each { |f| collection += fields_to_uncover(f, collection) unless f.is_uncovered? }
    collection
  end

  def valid_coordinates?(row, column)
    row.is_a?(Integer) &&
        column.is_a?(Integer) &&
        row >= 0 &&
        column >= 0 &&
        row < @grid_size &&
        column < @grid_size
  end
end