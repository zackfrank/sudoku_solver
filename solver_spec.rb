require_relative 'solver.rb'
require_relative 'board.rb'

RSpec.describe Solver do
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
    @solver = Solver.new(board: @board)
  end

  it "gives possibilities for a cell" do
    possibilities = @solver.analyze_cell(0, 0)
    expect(possibilities).to eq([6, 7, 9])
  end

  it "gives possibilities for a cell" do
    possibilities = @solver.analyze_cell(4, 5)
    expect(possibilities).to eq([3])
  end

  it "solves a cell" do
    expect(@board.cell_value(4, 5)).to eq(0)

    @solver.solve_cell(4, 5)
    expect(@board.cell_value(4, 5)).to eq(3)
  end

  it "doesn't solve a cell if it's already populated" do
    expect(@board.cell_value(0, 4)).to eq(4)
    
    @solver.solve_cell(0, 4)
    expect(@board.cell_value(0, 4)).to eq(4)
  end

  it "fills in the entire board" do
    @solver.fill_in
    expect(@board.cells.include? 0).to eq(false)
  end
  
end