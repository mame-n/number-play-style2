class Numplay
  def initialize
  end

  attr_accessor :grouping, :spec_group

  def sudoku( base = nil, grouping=nil, spec_group=nil )
    @grouping = grouping
    @spec_group = spec_group
    mtx( 80, base )
  end
  
  def mtx( h, base )
#    puts "h = #{h}"
    return base if h == -1

    row = h / 9
    col = h % 9

    if base[row][col] != 0
      return base if mtx( h - 1, base.dup )
    else
      (1..9).each do |candidate|
        next if check_dup?( row, col, base, candidate )

        base[row][col] = candidate
        ret = mtx( h - 1, base.dup )
        return ret if ret
      end
      base[row][col] = 0
    end
    nil
  end

  def check_dup?(row, col, base, candidate)
    if @grouping == nil
      return base[row].include?(candidate) \
      || base.transpose[col].include?(candidate) \
      || numbers_square( row, col, base ).include?(candidate)
    else
      cond01 = base[row].include?(candidate)
      cond02 = base.transpose[col].include?(candidate)
      cond03 = numbers_square( row, col, base ).include?(candidate)
      cond04 = is_sum_difference?( row, col, base, candidate )

#      if row == 2 && col == 3
#        puts "(#{row}, #{col}) candi #{candidate} : #{@grouping[row][col]} 01 #{cond01}, 02 #{cond02}, 03 #{cond03}, 04 #{cond04}"
#        pp base
#      end

      return cond01 || cond02 || cond03 || cond04

#      return base[row].include?(candidate) \
#      || base.transpose[col].include?(candidate) \
#      || numbers_square( row, col, base ).include?(candidate) \
#      || is_sum_difference?( row, col, base )
    end
  end

  def numbers_square(row, col, base)
    tl_row = row / 3 * 3
    tl_col = col / 3 * 3
    (tl_row..tl_row+2).map do |r|
      (tl_col..tl_col+2).map do |c|
        base[r][c]
      end
    end.flatten
  end

  def is_sum_difference?( target_row, target_col, base, candidate )
    target_group = @grouping[target_row][target_col]
    basedup = base.dup
    basedup[target_row][target_col] = candidate
    target_member = get_target_member( basedup, target_group )

    if target_row == 2 && target_col == 3
#      puts "g #{target_group} m #{target_member}"
    end

    if target_member.any?(0)
      return false
    else
      sum_group = target_member.inject(0) { |sum,member| sum + member }
      return sum_group != @spec_group[target_group]
    end
  end
    
  def get_target_member(base, target_group)
    group = []
    @grouping.each_with_index do |row_nums,row_posi|
      row_nums.each_with_index do |col_num,col_posi|
        if @grouping[row_posi][col_posi] == target_group
          group << base[row_posi][col_posi] 
        end
      end
    end
    group
  end

  def sum_of_numbers(target_row, target_col, base, grouping)
#    grouping = [[0,0,0],[1,1,2],[1,0,3],[3,4,0]] row-col
#    spec_group[12,4,31,1] grouping number is a key.

    target_group = grouping[target_row][target_col]

    sum = 0
    (0..8).each do |row|
      (0..8).each do |col|
        sum += base[row][col] if grouping[row][col] == target_group
      end
    end
#    puts "Sum : #{sum} - #{target_group} -- (#{target_row},#{target_col})"
    sum
    
  end

end
