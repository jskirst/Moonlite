require 'csv'
require 'zip/zip'
require 'set'

module UploadHelper
  def read_file(file)
    @files = {}
    @file_root = nil
    @file_path = get_file_path(file)
    Zip::ZipFile.open(@file_path) do |zipfile|
      zipfile.each do |file|
        @file_root ||= file.to_s.split("/")[0]
        @files[file.to_s] = zipfile.read(file.to_s)
      end
    end
    return @files.keys
  end
  
  def get_file_path(file)
    return file.path
  end
  
  def get_path_description
    return @files[@file_root+"/description.html"]
  end
  
  def get_section(section)
    file = @files[@file_root+"/sections/"+section.to_s+"/instructions.html"]
    name = nil
    instructions = ""
    unless file.nil?
      file.each_line do |line|
        if name.nil?
          name = line.gsub("#", "").chomp
        else
          instructions += line
        end
      end
      return {:name => name, :instructions => instructions.chomp}
    end
    return nil
  end
  
  def get_section_tasks(section)
    file_name = @file_root+"/sections/"+section.to_s+"/tasks.csv"
    tasks_file = @files[file_name]
    return parse_file(tasks_file) unless tasks_file.nil?
    return nil
  end
  
  def parse_file(uploaded_file_string)
    new_tasks = []
    if @tab_delimited
      parsed_file = []
      uploaded_file_string.each_line do |line|
        parsed_line = line.chomp.split(/\t/)
        logger.debug parsed_line
        parsed_file << parsed_line
      end
    else
      parsed_file = CSV.parse(uploaded_file_string)
    end
    if file_properly_formatted?(parsed_file)
      row_count = 0
      parsed_file.each do |row|
        if row_count != 0
          new_tasks << create_task(row)
        end
        row_count += 1
      end
      if @collected_answers
        new_tasks = insert_wrong_answers(new_tasks)
      end
      return new_tasks
    else
      return nil
    end
  end
		
  def file_properly_formatted?(parsed_file)
    file_header = parsed_file[0]
    if file_header[0] =~ /question/i &&
      file_header[1] =~ /correct answer/i &&
      file_header[2] =~ /wrong answer/i &&
      file_header[3] =~ /wrong answer/i &&
      file_header[4] =~ /wrong answer/i
      return true
    else
      return false
    end
  end
		
  def create_task(row)
    question = row[0].chomp unless row[0].nil?
    answers = []
    answers << row[1].chomp unless row[1].nil?
    answers << row[2].chomp unless row[2].nil?
    answers << row[3].chomp unless row[3].nil?
    answers << row[4].chomp unless row[4].nil?
    answers = answers.shuffle
    correct_answer = answers.index(row[1].chomp) + 1
    points = 10
    task = { :question => question,
      :answer1 => answers[0],
      :answer2 => answers[1],
      :answer3 => answers[2],
      :answer4 => answers[3],
      :correct_answer => correct_answer,
      :points => points }
    return task
  end
  
  def insert_wrong_answers(tasks)
    answer_collection = []
    tasks.each do |t|
      unless is_predictable?(t[:answer1])
        answer_collection.push(t[:answer1])
      end
    end
    answer_collection = answer_collection.uniq
    answer_collection_size = answer_collection.size - 1
    tasks.each do |t|
    
      correct_answer = t[:answer1]
      answers = []
      answers << t[:answer2] if t[:answer2]
      answers << t[:answer3] if t[:answer3]
      answers << t[:answer4] if t[:answer4]
      
      unless answers.size > 0
        correct_answer_index = answer_collection.index(correct_answer)
        predictable_type = is_predictable?(correct_answer)
        if predictable_type
          answers = predict_answers(correct_answer, predictable_type)
        else
          logger.debug correct_answer_index
          logger.debug answer_collection_size
          random_order = random_set(3, answer_collection_size, [correct_answer_index])
          answers << t[:answer1]
          answers << answer_collection[random_order[0]]
          answers << answer_collection[random_order[1]] if random_order[1]
          answers << answer_collection[random_order[2]] if random_order[2]
        end
      else
        answers << t[:answer1]
      end
      
      answers = answers.shuffle
      unless predictable_type == "bool"
        answer_index = answers.index(correct_answer)
        raise "Can't find correct answer in list of answers. Answer: "+correct_answer+"; Answers: "+answers.to_s if answer_index.nil?
        correct_answer = answer_index + 1
      else
        correct_answer = answers.index("true")
        correct_answer = answers.index("false") if correct_answer.nil?
        correct_answer += 1
      end
      t[:answer1] = answers[0]
      t[:answer2] = answers[1]
      t[:answer3] = answers[2] if answers[2]
      t[:answer4] = answers[3] if answers[3]
      t[:correct_answer] = correct_answer
    end
    return tasks
  end
  
  def is_predictable?(answer)
    answer = answer.downcase
    begin
      Integer(answer)
      return "int"
    rescue ArgumentError
      logger.debug "NOT INT"
    end
    
    return (answer == "false" || answer == "true" ? "bool" : false)
  end

  def predict_answers(answer, type = nil)
    logger.debug "PREDICTING"
    type = is_predictable?(answer) if type == nil
    answers = []
    if type == "int"
      answers = random_range_series(answer, 4)
      answers = answers.map! {|a| a.to_s}
    elsif type == "bool"
      answer = answer.downcase
      answers << answer
      answers << (answer == "false" ? "true" : "false")
    else
      logger.debug "FUCK: Invalid predictable type."
    end
    return answers
  end

  def random_range_series(num, length)
    num = Integer(num)
    if num < 10
      max_diff = 4
    elsif num < 100
      max_diff = 30
    else
      max_diff = num / 50
    end
    new_nums = Set.new
    new_nums << num
    loop_counter = 0
    loop do
      loop_counter += 1
      if loop_counter >= 1000
        raise "Possible infinite loop in random range series"
      end
      diff = rand(max_diff)
      new_num = (rand(2) == 1 ? (num + diff) : (num - diff))
      if num < 2012 
        if new_num >= 0 && new_num <= 2012
          new_nums << new_num
        end
      else
        new_nums << new_num
      end 
      return new_nums.to_a if new_nums.length >= length
    end
  end
  
  def random_set(length, max, excluded_nums = [])
    if max <= length
      length = max - 1
    end
    randoms = Set.new
    loop_counter = 0
    loop do
      loop_counter += 1
      if loop_counter >= 1000
        raise "Possible infinite loop in random set"
      end
      n = rand(max)
      unless excluded_nums.include?(n)
        randoms << n
      end
      return randoms.to_a if randoms.length >= length
    end
  end
end
