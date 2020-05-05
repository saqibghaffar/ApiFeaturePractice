class CodingExerciseGenerator < Rails::Generators::NamedBase
  require "bundler"
  Bundler.require(:tasks)
  require "active_support/core_ext/string/indent"

  source_root File.expand_path('../templates', __FILE__)

  class UnknownExerciseError < StandardError; end

  def do_the_things
    case file_name
    when "1", "first"
      set_up_first_exercise
    when "2", "second"
      set_up_second_exercise
    when "3", "third"
      set_up_third_exercise
    else
      raise UnknownExerciseError
    end
  end

  private

  def set_up_first_exercise
    puts "Setting up exercise 1!"

    # copy tests over
    inject_into_file "test/controllers/api/ratings_controller_test.rb", after: "class Api::RatingsControllerTest < ActionDispatch::IntegrationTest" do
      "\n\n" + load_tests(:exercise_1_ratings_controller).indent(2)
    end
    inject_into_file "test/controllers/api/trucks_controller_test.rb", after: "class Api::TrucksControllerTest < ActionDispatch::IntegrationTest" do
      "\n\n" + load_tests(:exercise_1_trucks_controller).indent(2)
    end
  end

  def set_up_second_exercise
    puts "Setting up exercise 2!"

    # add geocoder gem
    gem "geocoder"

    # bundle
    Bundler.with_clean_env do
      run "bundle install"
    end

    # copy tests over
    inject_into_file "test/controllers/api/trucks_controller_test.rb", after: "# EXERCISE 2 - DO NOT DELETE THIS LINE" do
      "\n\n" + load_tests(:exercise_2).indent(2)
    end
  end

  def load_tests(name)
    File.read(File.expand_path("#{name}_tests.rb", self.class.source_root))
  end

  def set_up_third_exercise
    puts "Setting up exercise 3!"

    gem "timecop", group: :test, version: "0.9.1"

    # bundle
    Bundler.with_clean_env do
      run "bundle install"
    end

    # copy tests over
    inject_into_file "test/controllers/api/trucks_controller_test.rb", after: "# EXERCISE 3 - DO NOT DELETE THIS LINE" do
      "\n\n" + load_tests(:exercise_3).indent(2)
    end
  end
end
