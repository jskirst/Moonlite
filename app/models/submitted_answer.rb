require 'open-uri'
class SubmittedAnswer < ActiveRecord::Base
  POINTS_PER_VOTE = 50

  attr_protected :task_id, :total_votes, :locked_at, :reviewed_at, :has_comments
  attr_accessible :url, 
    :content, 
    :caption,
    :description,
    :title,
    :image_url,
    :site_name,
    :preview,
    :preview_errors
  
  belongs_to :task
  has_one :completed_task, dependent: :destroy
  has_one :path, through: :completed_task
  has_one :user, through: :completed_task
  has_many :comments, -> { where "locked_at is NULL" }, as: :owner
  has_many :votes, as: :owner, dependent: :destroy
  has_many :stored_resources, as: :owner
 
  validates :content, length: { maximum: 100000 }
  
  after_save :flush_cache
  before_destroy :flush_cache
  
  def reviewed?() not reviewed_at.nil? end
  
  def submit!(completed_task, user, publish, args)
    args.delete_if{ |arg| arg.blank? }
    
    self.content = args[:content]
    self.url = args[:url]
    self.image_url = args[:image_url]
    self.title = args[:title]
    self.description = args[:description]
    self.caption = args[:caption]
    self.site_name = args[:site_name]
    self.locked_at = nil
    self.reviewed_at = nil
    evaluate_content if content

    if args[:stored_resource_id].presence
      resource = StoredResource.assign(args[:stored_resource_id], self) 
      self.image_url = resource.obj.url
    end

    if publish and not user.guest_user?
      self.reviewed_at = Time.now
    end
    save!
    
    completed_task.submitted_answer_id = self.id
    correct_answers = Answer.cached_find_by_task_id(completed_task.task_id).select{ |t| t.is_correct }
    if correct_answers.size > 0
      correct = correct_answers.any?{ |answer| answer.match?(preview.to_s) }
      if correct or correct_answers.empty?
        completed_task.status_id = Answer::CORRECT
        if publish and completed_task.points_awarded.to_i == 0
          completed_task.points_awarded = CompletedTask::CORRECT_POINTS
          completed_task.award_points = true
        end
      else
        completed_task.status_id = Answer::INCORRECT
      end
    else
      if publish and completed_task.points_awarded.to_i == 0
        completed_task.status_id = Answer::CORRECT
        completed_task.points_awarded = CompletedTask::CORRECT_POINTS
        completed_task.award_points = true
      end
    end
    completed_task.save!
  end
  
  def evaluate_content
    return false if content.blank?
    if content.include?("#ruby")
      url = "http://www.evaluatron.com/" 
      default_error = "Syntax Error"
    elsif content.include?("//php")
      url = "http://evaluatronphp.herokuapp.com/" 
      default_error = "Syntax Error - check your semicolons and braces."
    end
    
    if url
      begin
        url = URI.parse("#{url}?quarry=#{CGI.escape(content)}")
        result = JSON.parse(open(url).read)
        self.preview = result["output"]
        self.preview_errors = result["errors"]
      rescue
        self.preview = nil
        self.preview_errors = default_error
      end
    end
    return true
  end
  
  
  # Voting
  
  def add_vote(voting_user)
    if vote = voting_user.votes.create!(owner_id: self.id)
      self.total_votes += 1
      completed_task.update_attribute(:points_awarded, (completed_task.points_awarded += POINTS_PER_VOTE))
      user.award_points(vote, POINTS_PER_VOTE)
      return vote if save
    end
    return false
  end
  
  def subtract_vote(voting_user, vote)
    vote.destroy
    if self.total_votes > 0
      self.total_votes -= 1
      completed_task.update_attribute(:points_awarded, (completed_task.points_awarded -= POINTS_PER_VOTE))
      completed_task.user.retract_points(vote, POINTS_PER_VOTE)
      return true if save
    else
      raise "Fatal: Have negative votes somehow"
    end
    return false
  end
  
  # Mail Alert
  
  def self.inductions(time)
    where("promoted_at > ?",time)
  end
  
  def send_induction_alert(deliver = false)
    raise "Not inducted: "+self.to_yaml if promoted_at.nil?
    m = Mailer.induction_alert(self)
    m.deliver if deliver
  end
  
  def self.send_all_induction_alerts(time, deliver = false)
    inductions(1.hour.ago).each { |i| i.send_induction_alert(deliver) }
  end
  
  # Cached methods
  
  def self.cached_find(id)
    Rails.cache.fetch([self.to_s, id]){ find_by_id(id) }
  end
  
  def flush_cache
    Rails.cache.delete([self.class.name, id])
  end
end
