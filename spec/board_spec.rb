require 'spec_helper'

describe Board do
  let(:grid_size) { 10 }
  let(:num_bombs) { 10 }
  let(:board) { Board.new(grid_size, num_bombs) }


  describe "#new" do
    it "returns a Board object" do
      expect(board.class).to eq Board
    end
    it "sets the correct grid size" do
      expect(board.grid_size).to eq grid_size
    end
    it "sets the correct number of bombs" do
      expect(board.num_bombs).to eq num_bombs
    end
    it "creates all fields" do
      expect(board.fields.first.class).to eq Field
      expect(board.fields.length).to eq grid_size**2
    end
    it "sets all bombs in the fields" do
      expect(board.fields.select {|field| field.has_bomb?}.length).to eq num_bombs
    end
    it "calculates sets the number of surrounding bombs in the fields next to a bomb" do
      num_fields = board.fields.select {|field| field.has_number?}
      num_field = num_fields.sample
      surrounding_fields = collect_surrounding_fields(board, num_field)
      expect(num_fields.length).to be > 0
      expect(num_field.touching_bombs).to be selected_fields(surrounding_fields, :for_content, 'bomb').length
    end

  end

  describe ".get_field_in_grid" do
    let(:field) { board.fields.sample }
    let(:row) { field.row }
    let(:column) { field.column }

    context "when coordinates within the grid" do
      it "returns a Field object" do
        result = board.get_field_in_grid(row, column)
        expect(result.class).to eq Field
      end

      it "returns the field with the right row and column attributes" do
        result = board.get_field_in_grid(row, column)
        expect(result).to eq field
      end
    end

    context "when coordinates outside the grid" do
      it "returns nil" do
        expect(board.get_field_in_grid(board.grid_size+4, -1)).to be nil
      end
    end
  end

  describe ".covered_fields" do
    before(:all) do
      @board2 = Board.new(10,10)
      @board2.fields.sample.covered = false
    end

    context "when new board" do
      it "returns all fields" do
        expect(board.covered_fields.sort_by{|f| f.row}.sort_by{|f| f.column}).to eq board.fields.sort_by{|f| f.row}.sort_by{|f| f.column}
      end
    end

    context "when board was played on" do
      it "returns all covered fields" do
        expect(@board2.covered_fields.sort_by{|f| f.row}.sort_by{|f| f.column}).to_not eq board.fields.sort_by{|f| f.row}.sort_by{|f| f.column}
      end
    end
  end

  describe ".num_of_covered_fields" do
    before(:all) do
      @board2 = Board.new(10,10)
      @board2.fields.sample.covered = false
    end

    context "when new board" do
      it "returns the sum of all fields" do
        expect(board.num_of_covered_fields).to eq board.fields.length
      end
    end

    context "when board was played on" do
      it "returns the sum of all covered fields" do
        expect(@board2.num_of_covered_fields).to_not eq board.fields.length
      end
    end
  end

  describe ".uncover_surrounding_fields" do
    let(:field) { selected_fields(board.fields, :for_content, nil).sample }
    let(:field) { selected_fields(board.fields, :for_content, nil).sample }
    let(:run_method) { board.uncover_surrounding_fields(field) }

    it "should uncover all empty fields and the first row of number fields" do
      expect(board.covered_fields.length).to eq board.fields.length
      run_method
      expect(board.covered_fields.length).to_not eq board.fields.length
      expect(selected_fields(board.fields, :for_cover, 'uncovered').length).to be > 1
    end
  end

  describe ".position_of_covered" do
    before(:all) do
      @board2 = Board.new(10,10)
      @board2.fields.sample.covered = false
      @result2 = @board2.position_of_covered
    end

    context 'when board is new' do
      let(:result) { board.position_of_covered }
      it "returns a Hash" do
        expect(result.class).to eq Hash
        [:in_the_middle, :on_the_edge].each do |key|
          expect(result.keys).to include key
        end
        expect(result[:in_the_middle].class).to eq Array
        expect(result[:on_the_edge].class).to eq Hash
        expect(result[:on_the_edge].keys.count).to eq 0
      end
    end

    context 'when fields are uncovered' do

      it "returns a Hash" do
        expect(@result2.class).to eq Hash
        [:in_the_middle, :on_the_edge].each do |key|
          expect(@result2.keys).to include key
        end
        expect(@result2[:in_the_middle].class).to eq Array
        expect(@result2[:on_the_edge].class).to eq Hash
        expect(@result2[:on_the_edge].keys.count).to be > 0

        key = @result2[:on_the_edge].keys.first.to_s
        expect(@result2[:on_the_edge][key].class).to eq Array
        expect(@result2[:on_the_edge][key].first[:field].class).to eq Field
        expect(@result2[:on_the_edge][key].first[:sum].class).to eq Fixnum
      end

    end
  end

end