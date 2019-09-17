require_relative 'solver.rb'
require_relative 'board.rb'

RSpec.describe Solver do
  before(:each) do
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
    @solver = Solver.new(board: @board)
  end

  it "fills in a duplicate board" do
    expect(@solver.board.cell_value(4, 5)).to eq(0)

    @solver.fill_in_board
    expect(@solver.filled_in_board.cell_value(4, 5)).to eq(3)
  end

  it "doesn't solve a cell if it's already populated" do
    expect(@solver.board.cell_value(0, 4)).to eq(4)
    
    @solver.fill_in_board
    expect(@solver.filled_in_board.cell_value(0, 4)).to eq(4)
  end

  it "fills in the entire board" do
    @solver.fill_in_board
    expect(@solver.board.cells.include? 0).to eq(false)
  end
  
end