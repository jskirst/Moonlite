class EvaluationExport < Prawn::Document
  def initialize(evaluation_enrollment, view)
    super()
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
    title
    @results.each do |r|
      path(r)
    end
  end

  # = image_tag @user.picture, style:"display:inline; height:61px;", alt: "Stoney"
  # %div{ style: "display: inline-block; vertical-align: top; margin-left: 5px; "}
  #   %h2{ style: "font-size: 30px; margin-bottom: -10px; margin-top: -3px; " }= @user.name
  #   - if @evaluation
  #     %h3{ style: "font-size:20px; "}
  #       = link_to @evaluation.title, group_evaluation_path(@group, @evaluation)
  # %div{ style: "display: inline-block; vertical-align: top; float: right; text-align: right; margin-top: 10px; "}
  #   %h3{ style: "font-size:17px; line-height: 25px"}
  #     = link_to @user.email, "mailto:#{@user.email}"
  #   - if @user.country
  #     - country = Carmen::Country.coded(@user.country)
  #     %h3{ style: "font-size:17px; line-height: 25px"} #{@user.city}, #{country.subregions.coded(@user.state).name}, #{country.name}
  #   %h4= link_to "Export (PDF)", export_group_evaluation_path(@group, @evaluation, u: @user)
  def title
    text_box @user.name, size: 16, align: :left, width: 200
    text @user.email, align: :right, size: 11
    if @user.country
      country = Carmen::Country.coded(@user.country)
      location = "#{@user.city}, #{country.subregions.coded(@user.state).name}, #{country.name}"
      text location, align: :right, size: 11
    end
    stroke_horizontal_rule
  end

  def path(results)
    move_down 20
    overall(results)
    creative(results)
    multiple(results)
  end

  # - path = Path.where(name: r[:name]).first
  # .evaluation.hide{ id: r[:permalink] }
  #   - is_difficult = path.difficult?
  #   - unless is_difficult
  #     = render "paths/difficulty_warning"
  #   .header{ style: "padding-left: 0;"}
  #     %h3 Candidate Summary

  #     .metascore_graph{ :data => { "metascore" => ms_for_graph, "skill" => skill_level } }
  #     .clear_floats
  #   .challenge_stats
  #     -# .myrank
  #     -#   %span #
  #     -#   %p Percentile Rank
  #     .big_skill_space
  #       .big_skill.label{ class: skill_level.downcase}
  #         = skill_level
  #       .text
  #         MetaScore Ranking
  #         .ms{ style: "display: inline-block;" }                    
  #           .tip-below{ style: "display: inline-block;", data: {tip: "This is the skill level MetaBright estimates this person to possess in this Challenge. Our algorithm takes analyzes many variables to reach this conclusion such as question difficulty, content topic, and responder speed. Question difficulty is dynamically calculated, so it's possible for your candidates' MetaScores to slightly shift as question difficulties evolve."}}
  #             %img{src: "https://s3.amazonaws.com/moonlite-nsdub/static/random+icons/tooltip_light.png", style: "width: 16px; height: 16px; display: inline-block; margin-bottom: 3px;"}
  #     %table.table.overview
  #       %tbody
  #         %tr
  #           %td.table_tip
  #             - if r[:core].empty?
  #               %h3 --
  #               %p.tip-below{ data: {tip: "There aren't any multiple choice questions in this Challenge."}} Correct MC
  #             - else
  #               %h3 #{r[:performance].percent_correct}%
  #               %p.tip-below{ data: {tip: "Percent of multiple choice questions answered correctly."}} Correct MC
  #           %td.table_tip
  #             - if r[:core].empty?
  #               %h3 --
  #               %p.tip-below{ data: {tip: "There aren't any multiple choice questions in this Challenge."}} Avg. Time per MC
  #             - else
  #               %h3 #{r[:performance].avg_time_to_answer.round(1)}s
  #               %p.tip-below{ data: {tip: "Average response time per correct multiple choice question."}} Avg. Time per MC
  #           %td.table_tip
  #             - if r[:creative].count == 0
  #               %h3 --
  #               %p.tip-below{ data: {tip: "There are no Creative Response questions in this Challenge."}} Creative Response 
  #             - else
  #               %h3= r[:creative].count {|x| not x.content.blank? }.to_s+"/"+r[:creative].count.to_s
  #               %p.tip-below{ data: {tip: "Number of submitted Creative Response questions out of total available."}} Creative Response
  #     - unless path.group_id?
  #       .strengths_weaknesses
  #         .strengths 
  #           .header{ style:"font-size: 16px; border-bottom: 1px solid rgba(0,0,0,.1);"}
  #             Strengths
  #           .body
  #             - if r[:performance].strengths.empty?
  #               %p{ style: "font-size: 12px;" } More data required.
  #             - else
  #               %ul
  #                 - r[:performance].strengths.first(3).each do |topic_name, stats|
  #                   %li= topic_name
  #         .weaknesses 
  #           .header{ style:"font-size: 16px; border-bottom: 1px solid rgba(0,0,0,.1);"}
  #             Weaknesses
  #           .body
  #             - if r[:performance].weaknesses.empty?
  #               %p{ style: "font-size: 12px;" } More data required.
  #             - else
  #               %ul
  #                 - r[:performance].weaknesses.first(3).each do |topic_name, stats|
  #                   %li= topic_name
  def overall(r)
    path = r[:path]
    text path.name, size: 16
    move_down 10
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
      skill_level.size = 15
      skill_level.width = 120
      skill_level.align = :center
      skill_level.valign = :center
      columns(1..3).width = 125
    end
  end

  # - if r[:creative].any?
  #   %div
  #     %a.header_link{ "data-target" => "#cr", "data-toggle" => "collapse", :type => "button"}  Creative Response
  #     #cr.collapse.in{ style: "margin-bottom: 20px;"}
  #       %ol
  #         - r[:creative].each do |completed_task|
  #           %li
  #             - total_time = (completed_task.updated_at - completed_task.created_at).round(0)
  #             - total_time = creative_time_to_answer if total_time > 600
  #             - minutes = (total_time.to_f / 60).round(0)
  #             - seconds = (total_time.to_f % 60).round(0)
  #             .answer
  #               - task = completed_task.task
  #               %p= task.question
  #               - if completed_task.submitted_answer.try(:content).blank?
  #                 .skipped_cr
  #                   %img{ src: "https://s3.amazonaws.com/moonlite-nsdub/static/random+icons/warning.png"}
  #                   %p{ style: "display: inline-block; "} Candidate skipped this question. 
  #               - else
  #                 %pre= completed_task.submitted_answer.try(:content).to_s
  #                 .time_taken_container
  #                   .time_taken 
  #                     Completed in 
  #                     - if minutes != 0 
  #                       #{minutes} minutes 
  #                     - if seconds != 0
  #                       #{seconds} seconds
  def creative(r)
    move_down 15
    return true if r[:creative].empty?
    text "Creative Response", size: 14
    r[:creative].each_with_index do |completed_task, i|
      move_down 10
      total_time = (completed_task.updated_at - completed_task.created_at).round(0)
      total_time = creative_time_to_answer if total_time > 600
      minutes = (total_time.to_f / 60).round(0)
      seconds = (total_time.to_f % 60).round(0)
      task = completed_task.task
      answer = completed_task.submitted_answer
      content = answer.content
      text "#{i+1}. #{task.question}", size: 11
      move_down 8
      bounding_box([0, cursor], width: 500) do
        move_down 8
        indent(10) do
          if content.blank?
            text "Candidate skipped this question", size: 10
          else
            text content, size: 10
          end
        end
        move_down 6
        transparent(0.3) { stroke_bounds }
      end
      move_down 5
      text "Completed in #{minutes} minutes and #{seconds} seconds", size: 7
    end
  end

  # - if r[:core].any?
  #   %div
  #     %a.header_link Multiple Choice
  #     %div
  #       %ol
  #         - r[:core].each do |completed_task|
  #           %li{ data: {  id: completed_task.id, created: completed_task.created_at, updated: completed_task.updated_at } }
  #             .answer
  #               - task = completed_task.task
  #               %p= task.question
  #               - if task.quoted_text
  #                 %pre= task.quoted_text
  #               = difficulty_label(task)
  #               - if completed_task.correct?
  #                 .time_taken{ style: "float: right;"} Correct, #{completed_task.points_awarded} points
  #               - else
  #                 .time_taken.incorrect{ style: "float: right;"}  Incorrect
  #               %div{ style: "margin-top: 10px;"} 
  #                 Correct answer:
  #                 %pre= task.correct_answer.content # Correct answer
  #               - if not completed_task.correct?
  #                 %div 
  #                   User response:
  #                   %pre= completed_task.answer # User supplied answer
  def multiple(r)
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
      
      status_color = completed_task.correct? ? "d9534f" : "5cb85c"
      table [[completed_task.answer]] do
        column(0).padding = 6
        column(0).size = 10
        column(0).background_color = status_color
        column(0).width = 300
        cells.text_color = "FFFFFF"
        cells.border_color = "FFFFFF"
        cells.padding_left = 10
      end
      move_down 10

      if completed_task.correct?
        text "Correct, #{completed_task.points_awarded} points", size: 11
      else
        text "Correct Answer: #{task.correct_answer.content}", size: 11
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