class Field
  attr_reader :row, :column, :touching_bombs
  attr_accessor :content, :covered

  def initialize(row, column)
    @row, @column = row, column
    @content = nil
    @covered = true
    @touching_bombs = 0
  end

  def has_bomb?
    @content == 'bomb'
  end

  def has_number?
    @content == 'number'
  end

  def has_content?
    !@content.nil?
  end

  def is_uncovered?
    !@covered
  end

  def uncover
    @covered = false
    @lost = true if has_bomb?
  end

  def set_touching_number(num)
    @content = 'number'
    @touching_bombs = num
  end
end