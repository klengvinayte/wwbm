# Admin controller, only for filling the database of questions with files
# of a certain format
# Creates a new game, updates the status of the game according to the user's answers, gives hints
#
class QuestionsController < ApplicationController
  before_action :authenticate_user!

  # check if he is an admin
  before_action :authorize_admin!

  # GET /questions/new
  # Form for uploading a bundle of questions
  def new
  end

  # POST /questions
  # Processing a form containing a file with questions and a field - level
  def create
    level = params[:questions_level].to_i
    q_file = params[:questions_file]

    # reading the contents of the file into an array
    # http://stackoverflow.com/questions/2521053/how-to-read-a-user-uploaded-file-without-saving-it-to-the-database
    if q_file.respond_to?(:readlines)
      file_lines = q_file.readlines
    elsif q_file.respond_to?(:path)
      file_lines = File.readlines(q_file.path)
    else
      # if the file cannot be read, we send it to the new action with information about errors
      redirect_to new_questions_path, alert: "Bad file_data: #{q_file.class.name}, #{q_file.inspect}"
      return false
    end

    start_time = Time.now
    # In one big transaction, we create an array of questions at once, we consider the bad ones
    failed_count = create_questions_from_lines(file_lines, level)

    # we send it to the new page and display statistics on the operations performed
    redirect_to new_questions_path,
                notice: "Level #{level}, parsed #{file_lines.size}," +
                  " created #{file_lines.size - failed_count}," +
                  " time #{Time.at((Time.now - start_time).to_i).utc.strftime '%S.%L sec'}"
  end

  private

  def authorize_admin!
    redirect_to root_path unless current_user.is_admin
  end

  # Loading an array of questions in the database
  # For speed, we wrap everything in one transaction
  # см. https://www.coffeepowered.net/2009/01/23/mass-inserting-data-in-rails-without-killing-your-performance/
  def create_questions_from_lines(lines, level)
    failed = 0
    ActiveRecord::Base.transaction do
      lines.each do |line|
        ar = line.split('|')
        q = Question.create(
          level: level,
          text: ar[0].squish,
          answer1: ar[1].squish,
          answer2: ar[2].squish,
          answer3: ar[3].squish,
          answer4: ar[4].squish
        )
        failed += 1 unless q.valid?
      end
    end
    failed
  end
end
