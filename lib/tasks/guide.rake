require "pidfile"

include ExercisePidFileManager

Rake::TaskManager.record_task_metadata = true

desc "Start the exercises!"
task :start => ["guide:welcome", "guide:exercise1:start"]

desc "Print the current exercise's instructions."
task :help => ["guide:current", "guide:current_instructions", "guide:generic_help"]

desc "Commit your work and move on to the next exercise."
task :next => ["check_simple", "guide:next"]

desc "Mark your work on the entire coding exercise as complete. Everything but the push."
task :finish => ["guide:current", "guide:finish_all", "guide:thanks_and_goodbye"]

desc "Checks the status of the exercise"
task :check => ["guide:current", "db:test:prepare"] do
  sh "bin/rake test" do |ok, response|
    if ok || ENV["FORCE"] == "true"
      sep
      case current_exercise
      when :exercise1, :exercise2
      para <<-EOS
        All tests pass! You can move on to the next exercise with `rake next`
        or if you're tight on time, stop work and finalize your submission
        with `rake finish`.
      EOS
      when :exercise3
        puts "All tests pass! You can finalize your submission with `rake finish`."
      end
    else
      check_failed(status: response.exitstatus)
    end
  end
end

task :check_simple => ["db:test:prepare"] do
  sh "bin/rake test" do |ok, response|
    unless ok || ENV["FORCE"] == "true"
      check_failed(status: response.exitstatus)
    end
  end
end

namespace :guide do
  task :welcome do
    require_nothing_started

    puts <<-EOS

    ███████╗ ██╗████████╗ ██████╗ ██████╗ ██╗   ██╗██████╗
    ██╔════╝ ██║╚══██╔══╝██╔════╝ ██╔══██╗██║   ██║██╔══██╗
    ██║  ███╗██║   ██║   ██║  ███╗██████╔╝██║   ██║██████╔╝
    ██║   ██║██║   ██║   ██║   ██║██╔══██╗██║   ██║██╔══██╗
    ╚██████╔╝██║   ██║   ╚██████╔╝██║  ██║╚██████╔╝██████╔╝
     ╚═════╝ ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═════╝

    EOS

    current_branch = `git rev-parse --abbrev-ref HEAD`

    if current_branch.strip == "master"
      branchname = "github-interview-#{Date.today.strftime("%Y%m%d")}"
      sh "git checkout -b #{branchname}"
      sh "git push -u origin #{branchname}"
    end

    para <<-EOS
      Today you'll be working on the REST API for a food truck tracking
      application called GitGrub. For each step, we'll provide a basic endpoint
      with some failing tests to get you started. (While you're making those
      pass, feel free to add your own!)

      Your database will be seeded with some example food trucks for you to use
      while testing your changes in development. Please familiarize yourself
      with the schema before you begin.

      You'll start the exercise by getting your development environment
      running, installing dependencies and initializing a database. We've
      provided a setup script to do this for you.
    EOS

    if ask("Would you like to run it now?")
      sh "bin/setup"
    end
  end

  task :generic_help do
    sep
    puts "\nAvailable commands:\n\n"

    unless current_exercise
      puts "bin/rake start:\t" + Rake::Task[:start].comment
    end

    if current_exercise
      puts "bin/rake check:".ljust(20) + Rake::Task[:check].comment
      puts "bin/rake next:".ljust(20) + Rake::Task[:next].comment
      puts "bin/rake finish:".ljust(20) + Rake::Task[:finish].comment
    end

    puts "bin/rake help:".ljust(20) + Rake::Task[:help].full_comment
  end

  task :thanks_and_goodbye do
    puts <<-EOS

    ██╗  ██╗ ██████╗  ██████╗ ██████╗  █████╗ ██╗   ██╗██╗
    ██║  ██║██╔═══██╗██╔═══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝██║
    ███████║██║   ██║██║   ██║██████╔╝███████║ ╚████╔╝ ██║
    ██╔══██║██║   ██║██║   ██║██╔══██╗██╔══██║  ╚██╔╝  ╚═╝
    ██║  ██║╚██████╔╝╚██████╔╝██║  ██║██║  ██║   ██║   ██╗
    ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝

    EOS

    para <<-EOS
      It looks like your work here is done. Please push your branch up to the
      remote repository and open a Pull Request. Be sure to write the PR in the
      manner you'd write a PR as an engineer at GitHub.

      Thank you for your time. Have a nice day!
    EOS
  end

  task :current do
    if current = current_exercise
      puts "Currently working on #{human_name(current)}."
    elsif completed_exercises.blank?
      if ask("It looks like you haven't started the exercise yet. Would you like to begin?")
        Rake::Task[:start].invoke
        exit 0
      end
      exit 1
    else # all exercises have been marked complete
      para <<-EOS
        It looks like you're done with the exercises! Have you pushed your
        branch to the remote repository yet? Once you've done that, all
        that remains is to open a Pull Request with your changes.
      EOS
    end
  end

  task :current_instructions do
    if current = current_exercise
      Rake::Task["guide:#{current}:instructions"].invoke
    end
  end

  task :finish_all do
    if current_exercise
      if ask("Would you like to mark #{human_name(current_exercise)} complete?")
        Rake::Task["guide:#{current_exercise}:finish"].invoke
      else
        para "Okay. #{human_name(current_exercise)} will not be scored."
      end
    end

    completed = completed_exercises.map { |ex| human_name(ex) }

    if completed.present?
      puts "Finished exercises: #{completed.join(", ")}."
    else
      para "It looks like you haven't finished any of the exercises yet."
      exit 1
    end
  end

  task :next do
    if current = current_exercise
      Rake::Task["guide:#{current}:finish"].invoke
      if next_exercise = exercise_after(current)
        Rake::Task["guide:#{next_exercise}:start"].invoke
      end
    end
  end

  namespace :exercise1 do
    task :instructions do
      unless started?(:exercise1)
        para "Whoops! You can only print instructions for an exercise you have started."
        exit 1
      end

      puts <<-EOS

  ███████╗██╗  ██╗███████╗██████╗  ██████╗██╗███████╗███████╗     ██╗
  ██╔════╝╚██╗██╔╝██╔════╝██╔══██╗██╔════╝██║██╔════╝██╔════╝    ███║
  █████╗   ╚███╔╝ █████╗  ██████╔╝██║     ██║███████╗█████╗      ╚██║
  ██╔══╝   ██╔██╗ ██╔══╝  ██╔══██╗██║     ██║╚════██║██╔══╝       ██║
  ███████╗██╔╝ ██╗███████╗██║  ██║╚██████╗██║███████║███████╗     ██║
  ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝╚══════╝╚══════╝     ╚═╝

      EOS

      para <<-EOS
        We'd like to give our API consumers the ability to rate trucks. We've
        provided a `POST /trucks/1/ratings` endpoint and some tests to get you
        started.  Some things to keep in mind:
      EOS

      puts <<-EOS

  * Approach your solution as you would if you were contributing to a
    production application with external API consumers.
  * A user can only rate each truck once.
  * Valid ratings are whole numbers from 1-5 (5 being highest).
  * Ratings should be persisted in the database, but the storage model is
    up to you.
      EOS

      para <<-EOS
        Once ratings can be created, modify the `GET /trucks/1` endpoint to
        return a truck's average rating, rounded to the nearest half (e.g. an
        average rating of 4.3 rounds to 4.5).

        If it helps, you can copy these instructions into a file for easy
        reference or keep this output open in a secondary terminal window.

        Hint: `rake check` will check your work.
      EOS
    end

    task :set_pid do
      if ask("Ready to get started?")
        puts "Starting Exercise 1..."
        start(:exercise1)
      end
    end

    task :start => [:set_pid, :setup, :instructions]

    task :setup do
      sh "bin/rails g coding_exercise 1"
    end

    task :finish => [:check_simple] do
      finish(:exercise1)
      next if ENV["SKIP_COMMIT"] == "true"

      if ask("Ready to commit your work?")
        sh "git add ."
        sh "git commit -a --allow-empty -m 'Marking Exercise 1 Complete'" do |ok, response|
          unless ok
            para <<-EOS
              Something went wrong with that commit. Please commit your work
              and try again.
            EOS
            exit 1
          end
        end
      end
    end
  end

  namespace :exercise2 do
    task :set_pid do
      puts "Starting Exercise 2..."
      start(:exercise2)
    end

    task :start => [:set_pid, :setup, :instructions]

    task :instructions do
      unless started?(:exercise2)
        para "Whoops! You can only print instructions for an exercise you have started."
        exit 1
      end

      puts <<-EOS

  ███████╗██╗  ██╗███████╗██████╗  ██████╗██╗███████╗███████╗    ██████╗
  ██╔════╝╚██╗██╔╝██╔════╝██╔══██╗██╔════╝██║██╔════╝██╔════╝    ╚════██╗
  █████╗   ╚███╔╝ █████╗  ██████╔╝██║     ██║███████╗█████╗       █████╔╝
  ██╔══╝   ██╔██╗ ██╔══╝  ██╔══██╗██║     ██║╚════██║██╔══╝      ██╔═══╝
  ███████╗██╔╝ ██╗███████╗██║  ██║╚██████╗██║███████║███████╗    ███████╗
  ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝╚══════╝╚══════╝    ╚══════╝

      EOS

      para <<-EOS
        Using the geocoder gem which we've added to your Gemfile, add the ability to:
      EOS

      puts <<-EOS
  * set a truck's last known location
  * get a truck's distance from a point
      EOS

      para <<-EOS
        NOTE: You shouldn't need to use Geocoder's geocoding functionality for
        the purpose of this exercise, so it's fine to set the Geocoder gem's
        address_attr to nil in your model and skip geocoding altogether.

        We've added some tests for you to exercise these features, updating the
        truck's last known location in `PATCH /trucks/1` and sending an optional
        `near` parameter to the `GET /trucks` request to get the distances of
        trucks within 50 miles back in the response.

        We'd like you to return the distance in miles, rounded to 2 decimal
        places. Keep in mind that some trucks won't have a last known location!
      EOS
    end

    task :setup do
      sh "bin/rails g coding_exercise 2"
    end

    task :finish => [:check_simple] do
      finish(:exercise2)
      next if ENV["SKIP_COMMIT"] == "true"

      if ask("Ready to commit your work?")
        sh "git add ."
        sh "git commit -a --allow-empty -m 'Marking Exercise 2 Complete'" do |ok, response|
          unless ok
            para <<-EOS
              Something went wrong with that commit. Please commit your work
              and try again.
            EOS
            exit 1
          end
        end
      end
    end
  end

  namespace :exercise3 do
    task :set_pid do
      puts "Starting Exercise 3..."
      start(:exercise3)
    end

    task :start => [:set_pid, :setup, :instructions]

    task :setup do
      sh "bin/rails g coding_exercise 3"
    end

    task :instructions do
      unless started?(:exercise3)
        para "Whoops! You can only print instructions for an exercise you have started."
        exit 1
      end

      puts <<-EOS

  ███████╗██╗  ██╗███████╗██████╗  ██████╗██╗███████╗███████╗    ██████╗
  ██╔════╝╚██╗██╔╝██╔════╝██╔══██╗██╔════╝██║██╔════╝██╔════╝    ╚════██╗
  █████╗   ╚███╔╝ █████╗  ██████╔╝██║     ██║███████╗█████╗       █████╔╝
  ██╔══╝   ██╔██╗ ██╔══╝  ██╔══██╗██║     ██║╚════██║██╔══╝       ╚═══██╗
  ███████╗██╔╝ ██╗███████╗██║  ██║╚██████╗██║███████║███████╗    ██████╔╝
  ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝╚══════╝╚══════╝    ╚═════╝

      EOS

      para <<-EOS
        Add the ability for API consumers to search for trucks by minimum
        rating, whether they are open right now, and associated tags. Sample
        tags are provided in the seed data. All search criteria must be met, so
        use AND logic.
      EOS
    end

    task :finish => [:check_simple] do
      finish(:exercise3)

      if ENV["SKIP_COMMIT"] == "true"
        Rake::Task["guide:thanks_and_goodbye"].invoke
      elsif ask("Ready to commit your work?")
        sh "git add ."
        sh "git commit -a --allow-empty -m 'Marking Exercise 3 Complete'" do |ok, response|
          if ok
            Rake::Task["guide:thanks_and_goodbye"].invoke
          else
            para <<-EOS
              Something went wrong with that commit. Please commit your work
              and try again.
            EOS
            exit 1
          end
        end
      end
    end
  end
end

def ask(question)
  puts "\n"
  puts question + " (y/n)"

  begin
    input = STDIN.gets.strip.downcase
  end until %w(q quit y yes n no).include?(input)

  bye if %w(quit q).include?(input)

  %w(y yes).include?(input)
end

def paragraph(str)
  puts "\n"
  str.split(/(\n\r?){2}/).each(&:strip!).each do |p|
    puts wrap(p.gsub(/\s+/, " "))
  end
end
alias :para :paragraph

def wrap(str, width: ideal_width)
  str.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
end

def ideal_width
  @terminal_width ||= `tput cols`
  [78, @terminal_width.strip.to_i].min
end

def sep
  puts ""
  puts "/" * ideal_width
end

def check_failed(status: 1)
  sep
  para <<-EOS
    Looks like there's still at least one failing test. Once all tests are
    passing, you can #{"move on to the next exercise or" if current_exercise != :exercise3}
    mark this one complete.
  EOS
  exit status
end

def bye(message = nil)
  para message if message
  puts "Bye!"
  exit 0
end
