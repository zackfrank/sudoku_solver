# frozen_string_literal: true

require_relative 'board.rb'

class Solver
  attr_accessor :board, :filled_in_board, :change_count

  def initialize(board:)
    @board = board
    @change_count = 0
  end

  def fill_in_board
    @filled_in_board ||= board.dup # rename to solution?

    # allow a full cycle without solving if (0, 0) is last cell solved
    until !filled_in_board.cells.include?(0) || change_count > 161
      [*0..8].each do |x|
        [*0..8].each do |y|
          solve_cell(x, y)
          self.change_count += 1
        end
      end
    end
  end

  def solve_cell(x, y)
    return unless filled_in_board.empty_cell(x, y)

    possibilities = filled_in_board.cell_possibilities(x, y)
    possibilities -= aggregate_possibilities(x, y) unless possibilities.length == 1

    if possibilities.length == 1
      filled_in_board.set_value(x, y, possibilities[0])
      self.change_count = 0
    end
  end

  def aggregate_possibilities(x, y)
    column_possibilities = neighbor_possibilities(coords_of_column_neighbors(x, y))
    row_possibilities = neighbor_possibilities(coords_of_row_neighbors(x, y))

    exclusions = []
    exclusions << neighbor_exclusions(column_possibilities)
    exclusions << neighbor_exclusions(row_possibilities)

    exclusions.uniq
  end

  def coords_of_column_neighbors(x, y)
    [*0..8].reject { |n| n == y }.map { |y| [x, y] }
  end

  def coords_of_row_neighbors(x, y)
    [*0..8].reject { |n| n == x }.map { |x| [x, y] }
  end

  def neighbor_possibilities(coords_of_neighborhood)
    coords_of_neighborhood.map do |coords|
      filled_in_board.cell_possibilities(*coords)
    end.compact
  end

  def neighbor_exclusions(neighbor_possibilities)
    neighbor_possibilities.select do |possibilities|
      neighbor_possibilities.count(possibilities) == possibilities.length
    end
  end
end

# EASY
# b = Board.new(cells:
  # [
  #   0, 0, 2, 1, 0, 8, 5, 0, 3,
  #   0, 0, 0, 0, 2, 0, 9, 0, 7,
  #   8, 0, 0, 3, 9, 0, 0, 0, 0,
  #   3, 1, 7, 6, 0, 0, 0, 0, 0,
  #   4, 6, 0, 0, 5, 0, 0, 7, 2,
  #   0, 0, 0, 0, 0, 4, 8, 1, 6,
  #   0, 0, 0, 0, 7, 3, 0, 0, 5,
  #   5, 0, 6, 0, 1, 0, 0, 0, 0,
  #   1, 0, 3, 5, 0, 6, 7, 0, 0
  # ])

# MEDIUM
b = Board.new(cells:
  [
    0, 9, 0, 4, 0, 6, 0, 3, 0,
    8, 0, 0, 0, 0, 7, 0, 0, 9,
    2, 0, 3, 0, 8, 0, 0, 0, 4,
    0, 2, 9, 1, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 5, 8, 2, 0,
    5, 0, 0, 0, 7, 0, 6, 0, 1,
    3, 0, 0, 9, 0, 0, 0, 0, 7,
    0, 8, 0, 6, 0, 1, 0, 4, 0
  ])

# HARD
# b = Board.new(cells:
#   [
#     0, 0, 0, 3, 0, 6, 0, 5, 0,
#     0, 0, 3, 1, 0, 0, 9, 4, 0,
#     5, 0, 0, 0, 2, 0, 0, 0, 0,
#     2, 8, 0, 0, 0, 0, 7, 0, 0,
#     0, 3, 0, 0, 8, 0, 0, 6, 0,
#     0, 0, 6, 0, 0, 0, 0, 9, 4,
#     0, 0, 0, 0, 9, 0, 0, 0, 7,
#     0, 7, 9, 0, 0, 1, 5, 0, 0,
#     0, 2, 0, 8, 7, 0, 0, 0, 0
#   ])

##########################
s = Solver.new(board: b)
s.fill_in_board
s.filled_in_board.print_rows
# s.aggregate_possibilities(0, 6)
