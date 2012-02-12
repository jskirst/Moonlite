module OrderHelper
  # IN: [[1,1],[2,2]] / [[1,1],[2,1]]
  #OUT: [[2,1]]
  def find_changes(old, new)
    changes = []
    old.each_index do |i|
      old_el = old[i]
      new_el = new[i]
      changes << [old_el[0],new_el[1]] unless old[i] == new[i]
    end
    return changes
  end

  # IN: 2 / [[1,1],[2,2],[3,3]]
  #OUT: 1
  def get_index_of_position(target_position, ary)
    ary.each_index do |i|
      current_position = ary[i][1]
      if current_position == target_position
        return i
      end
    end
  end

  # IN: 3 / [[1,1],[2,2],[3,3]]
  #OUT: 2
  def get_index_of_id(target_id, ary)
    ary.each_index do |i|
      current_id = ary[i][0]
      if current_id == target_id
        return i
      end
    end
  end

  # IN: 3 / 1 / [[1,1],[2,2],[3,3]]
  #OUT: [[1,1],[2,2],[3,1]]
  def change_position_by_id(id, desired_position, ary)
    index = get_index_of_id(id, ary)
    ary[index][1] = desired_position
    return ary
  end

  # IN: 2 / [[1,1],[2,2],[3,3]]
  #OUT: 2
  def get_position_of_id(target_id, ary)
    ary.each_index do |i|
      current_id = ary[i][0]
      if current_id == target_id
        return ary[i][1]
      end
    end
  end

  # IN: 5 / 3
  #OUT: true
  # IN: 1 / 2
  #OUT: false
  def going_up?(current, desired)
    if current > desired
      return true
    else
      return false
    end
  end


  # IN: 1 / 3 / [[1,1],[2,2],[3,3],[4,4]]
  #OUT: [[1,2],[2,3],[3,4],[4,4]]
  def move_everything_down_between(upper, lower, ary)
    new_ary = Array.new(ary)
    new_ary.each do |a|
      if (upper..lower).cover?(a[1])
        a[1] += 1
      end
    end
    return new_ary
  end

  # IN: 2 / 4 / [[1,1],[2,2],[3,3],[4,4]]
  #OUT: [[1,1],[2,1],[3,2],[4,3]]
  def move_everything_up_between(lower, upper, ary)
    new_ary = Array.new(ary)
    new_ary.each do |a|
      if (upper..lower).cover?(a[1])
        a[1] -= 1
      end
    end
    return new_ary
  end

  # IN: [[1,4],[2,1],[3,2],[4,3]]
  #OUT: [[2,1],[3,2],[4,3],[1,4]]
  def sort_by_position(ary)
    return ary.sort { |a, b| a[1] <=> b[1] }
  end

  # IN: [[1,1],[2,2],[3,3],[4,4],[5,5]] / [[1,1],[2,2],[3,2],[4,4],[5,5]]
  #OUT: [[1,1],[3,2],[2,3],[4,4],[5,5]]
  # IN: [[1,1],[2,2],[3,3],[4,4],[5,5]] / [[1,1],[2,2],[3,3],[4,1],[5,5]]
  #OUT: [[4,1],[1,2],[2,3],[3,4],[5,5]]
  # IN: [[1,1],[2,2],[3,3],[4,4],[5,5]] / [[1,1],[2,2],[3,5],[4,4],[5,5]]
  #OUT: [[1,1],[2,2],[4,3],[5,4],[3,5]]
  def reorder(old, new)
    changes = find_changes(old, new)
    results = Array.new(old)
    changes.each do |c|
      id = c[0]
      desired_position = c[1]
      current_position = get_position_of_id(id, results)
      if going_up?(current_position,desired_position)
        results = move_everything_down_between(desired_position,current_position,results)
      else
        results = move_everything_up_between(desired_position,current_position,results)
      end
      results = change_position_by_id(id, desired_position, results)
      results = sort_by_position(results)
    end
    return results
  end
end
