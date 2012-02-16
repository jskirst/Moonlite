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
    parsed_file = CSV.parse(uploaded_file_string)
    if file_properly_formatted?(parsed_file)
      row_count = 0
      parsed_file.each do |row|
        if row_count != 0
          new_tasks << create_task(row)
        end
        row_count += 1
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
      file_header[4] =~ /wrong answer/i &&
      file_header[5] =~ /points/i
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
  
  def random_set(length, max)
    randoms = Set.new
    loop do
        randoms << rand(max)
        return randoms.to_a if randoms.length >= length
    end
  end
end
