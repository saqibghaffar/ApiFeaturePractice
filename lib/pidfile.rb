module ExercisePidFileManager
  class UnknownExerciseError < StandardError; end
  class ExerciseNotStartedError < StandardError; end
  class ExerciseAlreadyStartedError < StandardError; end

  ALL_EXERCISES = [:exercise1, :exercise2, :exercise3]

  def started?(task_name)
    File.exists?(pid_file(task_name))
  end

  def completed?(task_name)
    File.exists?("complete/#{pid_file(task_name)}")
  end

  def current_exercise
    ALL_EXERCISES.find do |name|
      started?(name)
    end
  end

  def exercise_after(ex)
    return unless ALL_EXERCISES.include?(ex)

    cursor = ALL_EXERCISES.index(ex)
    ALL_EXERCISES[cursor + 1] if cursor
  end

  def completed_exercises
    ALL_EXERCISES.select do |name|
      completed?(name)
    end
  end

  def human_name(task_name)
    task_name.to_s.gsub(/(\d)/, ' \1').capitalize
  end

  def pid_file_name(task_name)
    "#{task_name}.pid"
  end

  def pid_file(task_name)
    File.join("./", pid_file_name(task_name))
  end

  def completed_pid_file(task_name)
    File.join("./complete/", pid_file_name(task_name))
  end

  def require_started(task_name)
    unless started?(task_name)
      raise ExerciseNotStartedError.new("Hmm, it looks like you haven't started #{human_name task_name}.")
    end

    yield if block_given?
  end

  def require_nothing_started
    ALL_EXERCISES.each { |name| require_not_started(name) }
  end

  def require_not_started(task_name)
    if started?(task_name)
      raise ExerciseAlreadyStartedError.new("Hmm, it looks like you already started #{human_name task_name}. Try bin/rake help")
    end
  end

  def start(task_name)
    raise UnknownExerciseError unless ALL_EXERCISES.include?(task_name)

    ALL_EXERCISES.each { |name| require_not_started(name) }
    File.open(pid_file(task_name), "w") { |f| f << Process.pid }
  end

  def finish(task_name)
    require_started(task_name) do
      pid_file = pid_file(task_name)
      completed_pid_file = completed_pid_file(task_name)

      FileUtils.mv(pid_file, completed_pid_file) if File.exists?(pid_file)
    end
  end
end
