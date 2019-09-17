require_relative 'board.rb'

RSpec.describe Board do
  before(:all) do
    @board = Board.new(cells: 
    [
      0, 0, 2, 1, 0, 8, 5, 0, 3, 
      0, 0, 0, 0, 2, 0, 9, 0, 7, 
      8, 0, 0, 3, 9, 0, 0, 0, 0, 
      3, 1, 7, 6, 0, 0, 0, 0, 0, 
      4, 6, 0, 0, 5, 0, 0, 7, 2, 
      0, 0, 0, 0, 0, 4, 8, 1, 6, 
      0, 0, 0, 0, 7, 3, 0, 0, 5, 
      5, 0, 6, 0, 1, 0, 0, 0, 0, 
      1, 0, 3, 5, 0, 6, 7, 0, 0
    ])
  end

  it "gives possibilities for a cell" do
    possibilities = @board.cell_possibilities(0, 0)
    expect(possibilities).to eq([6, 7, 9])
  end

  it "gives possibilities for a cell" do
    possibilities = @board.cell_possibilities(4, 5)
    expect(possibilities).to eq([3])
  end
end