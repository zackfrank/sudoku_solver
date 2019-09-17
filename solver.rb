class Solver
  attr_accessor :board, :filled_in_board

  def initialize(board:)
    @board = board
  end

  def fill_in_board
    @filled_in_board ||= board.dup

    while filled_in_board.cells.include? 0 do
      [*0..8].each do |x|
        [*0..8].each do |y|
          solve_cell(x, y)
        end
      end
    end
  end

  def solve_cell(x, y)
    return unless filled_in_board.cell_value(x, y) == 0

    possibilities = filled_in_board.cell_possibilities(x, y)
    if possibilities.length == 1
      filled_in_board.set_value(x, y, possibilities[0])
    end
  end
end
