# GitHub Technical Exercise

For your technical exercise, you'll be contributing to a Food Truck directory
application called GitGrub. There are three exercises, each asking you to build
a part of GitGrub's API. You'll be guided through the exercises with a suite of
rake tasks, which will present instructions and ensure all tests pass before
you move on to the next round.

Get as far as you can, but don't panic if you don't finish all three exercises.
It's better to complete one or two of them well than to rush through all three.
In the end, you'll push your work up to a branch and open a pull request, which
will be reviewed by GitHub engineers. _Please reserve some time at the end to
write up the pull request._

## Prerequisites

Before you begin, ensure Ruby 2.4+ and Bundler are installed.

```
ruby -v
gem install bundler
bundle install
```

The final prerequisite is [Yarn](https://yarnpkg.com/lang/en/docs/install/).
There are a few ways to install it; choose the one that works best for your
machine.

## Getting started

Begin the first exercise with:

```
bin/rake start
```

### Other tasks to guide you along your way

Check your progress at any time with:

```
bin/rake check
```

Move on to the next exercise with:

```
bin/rake next
```

Print the instructions for the current exercise at any time with:

```
bin/rake help
```

## Wrapping Up

Mark all of your work as complete and stop the exercise with:

```
bin/rake finish
```

Finally, push your branch up to this repo and open a pull request. Please
write the pull request as you would in your normal course of work on a team.

## What we're looking for

We want you to submit a solution you're proud of and we want you to be
successful so here are some of the things we're looking for in a solution:

* Satisfy the requirements described in the exercise! :)
* We're big fans of automated tests to help us build quality software, so
  write tests for code and edge cases as you would if this was a production
  application.
* We like to see solutions that show familiarity with the language used,
  demonstrating good object oriented (or functional) programming principles
  without going overboard.
* Tell us about your solution in your PR write-up. What trade-offs did you
  make, if any?
