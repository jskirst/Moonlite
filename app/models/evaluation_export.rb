class EvaluationExport < Prawn::Document
  def initialize(evaluation_enrollment, view)
    super()
    @group = evaluation_enrollment.group
    @evaluation_enrollment = evaluation_enrollment
    @view = view
    @user = @evaluation_enrollment.user
    @evaluation = @evaluation_enrollment.evaluation

    @results = []
    @evaluation.paths.each do |path|
      enrollment = @user.enrollments.find_by_path_id(path.id)
      next unless enrollment
      @results << @view.extract_enrollment_details(enrollment)
    end
    brand
    title
    @results.each do |r|
      path(r)
    end
    footer
  end

  def footer
    repeat :all do
      canvas do
        bounding_box [bounds.left, bounds.bottom + 50], :width  => bounds.width, :height => 50, :padding => 12 do
          text_box "Candidate skill assessment of #{@user.name}.",
            :size => 8,
            :width => 600,
            :align => :left,
            :text_color => "333333",
            :at => [20, 25]
          text_box " Powered by: http://www.MetaBright.com",
            :size => 8,
            :width => 200,
            :align => :right,
            :text_color => "333333",
            :at => [395, 25]

        end
      end
    end
  end

  def brand
    if @group.image_url.nil? or @group.image_url == ""
      image "#{Rails.root}/app/assets/images/MB+logo+less+white+space.png",
      :fit => [250,100],
      :position => :center
    else
      image open("#{@group.image_url}"),
      :fit => [250,100],
      :position => :center
      move_down 15
      image "#{Rails.root}/app/assets/images/powered_by_metabright_300_wide.png",
      :width => 100,
      :position => :center
    end
  end

  def title
    move_down 10
    if @user.country
      country = Carmen::Country.coded(@user.country)
      location = "#{@user.city}, #{country.subregions.coded(@user.state).name}, #{country.name}"
    end
    contents = [
      [{ content: @user.name, rowspan: 2 }, @user.email],
      [
        location,
      ]
    ]
    table contents do
      columns(0).align = :left
      columns(0).valign = :bottom
      columns(1).align = :right
      columns(0).size = 16
      columns(1).size = 11
      columns(0).width = 255
      columns(1).width = 285
      columns(0..1).padding = 1
      columns(0..1).border_colors = ("ffffff")
    end
    stroke_horizontal_rule
  end

  def path(results)
    move_down 20
    overall(results)
    creative(results)
    multiple(results)
  end

  def overall(r)
    path = r[:path]
    text path.name, size: 16
    move_down 10
    if r[:performance].avg_time_to_answer.nil?
      raise "Nil?"
    end
    contents = [
      [{ content: r[:skill_level], rowspan: 2 }, "Correct MC", "Avg. Time per MC", "Creative Response"],
      [
        "#{r[:performance].percent_correct}%",
        "#{r[:performance].avg_time_to_answer.round(1)} secs",
        r[:creative].count {|x| not x.content.blank? }.to_s + "/" +r[:creative].count.to_s
      ]
    ]
    skill_color = skill_level_color(r[:skill_level])
    table contents do
      columns(0..3).align = :center
      columns(1..3).valign = :middle
      columns(1..3).size = 11
      skill_level = columns(0)
      skill_level.background_color = skill_color
      skill_level.text_color = "FFFFFF"
      skill_level.font_style = :bold
      skill_level.size = 17
      skill_level.width = 120
      skill_level.align = :center
      skill_level.padding_top = 12
      columns(1..3).width = 125
    end
  end

  def creative(r)
    move_down 15
    return true if r[:creative].empty?
    text "Creative Response", size: 14
    r[:creative].each_with_index do |completed_task, i|
      move_down 10
      total_time = (completed_task.updated_at - completed_task.created_at).round(0)
      total_time = @view.creative_time_to_answer if total_time > 7200
      minutes = (total_time.to_f / 60).round(0)
      seconds = (total_time.to_f % 60).round(0)
      task = completed_task.task
      text "#{i+1}. #{task.question}", size: 11
      move_down 8
      answer = completed_task.submitted_answer
      if answer.nil? or answer.content.blank?
        text "Candidate skipped this question", size: 10
      else
        #status_color = completed_task.correct? ? "5cb85c" : "d9534f"
        table [[answer.content]] do
          column(0).padding = 6
          column(0).size = 10
          #column(0).background_color = status_color
          column(0).width = 500
          #cells.text_color = "FFFFFF"
          cells.border_color = "BBBBBB"
          cells.padding_left = 10
        end
      end
      move_down 5
      text "Completed in #{minutes} minutes and #{seconds} seconds", size: 7
    end
  end

  def multiple(r)
    return true if r[:core].empty?
    move_down 20
    text "Multiple Choice", size: 14
    r[:core].each_with_index do |completed_task, i|
      move_down 15
      task = completed_task.task
      text "#{i+1}. #{task.question}", size: 12
      move_down 7
      if task.quoted_text
        bounding_box([0, cursor], width: 500) do
          move_down 6
          indent(10) do
            text task.quoted_text, size: 10
          end
          move_down 6
          transparent(0.3) { stroke_bounds }
        end
        move_down 7
      end

      status_color = completed_task.correct? ? "5cb85c" : "d9534f"
      table [[completed_task.answer]] do
        column(0).padding = 6
        column(0).size = 10
        column(0).background_color = status_color
        column(0).width = 300
        cells.text_color = "FFFFFF"
        cells.border_color = "FFFFFF"
        cells.padding_left = 10
      end
      move_down 5

      if completed_task.correct?
        text "Correct, #{completed_task.points_awarded} points", size: 11
      else
        if completed_task.answer.present?
          text "User Response: #{completed_task.answer} / Correct Answer: #{task.correct_answer.present? ? task.correct_answer.content : "--"}", size: 11
        else
          text "User skipped this question", size: 11
        end
      end
    end
  end

  def skill_level_color(skill_level)
    case skill_level.downcase
    when "expert" then "5cb85c"
    when "advanced" then "7DD368"
    when "competent" then "F0B64E"
    when "familiar" then  "rgba(223, 130, 69, 1)"
    when "novice" then "d9534f"
    else "BBBBBB" end
  end
end
