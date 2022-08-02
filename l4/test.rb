require "json"
require "diffy"
require "./setup_db.rb"
require "../lib/report"

@report = Report.new(__dir__)

today = Date.today

# Source of capture method: https://alphahydrae.com/2013/09/capturing-output-in-pure-ruby/
def capture(&block)
  stdout = StringIO.new
  $stdout = stdout

  result = block.call

  # Restore original STDOUT.
  $stdout = STDOUT

  stdout.string
end

def trimmed_backtrace(backtrace)
  if backtrace.length <= 10
    backtrace
  else
    ["First 10 lines of backtrace:"] + backtrace[0..9]
  end.join("\n")
end

# First, let's try to require the todo.rb file.
begin
  require "./todo.rb"
rescue LoadError, StandardError => e
  @report.add_feedback("require_error", message_and_backtrace: @report.translate("message_and_backtrace", message: e.message, backtrace: trimmed_backtrace(e.backtrace)))
  @report.publish
  exit
end

# With the class loaded, let's try to add some tasks.
begin
  Todo.add_task(todo_text: "Pay rent", due_in_days: 0)
  Todo.add_task(todo_text: "Service vehicle", due_in_days: 0)
  Todo.add_task(todo_text: "File taxes", due_in_days: 1)
  Todo.add_task(todo_text: "Call Acme Corp.", due_in_days: 1)
  Todo.add_task(todo_text: "Submit assignment", due_in_days: -1)

  output = capture do
    Todo.show_list
  end

  expected_output = <<~EXPECTED
    My Todo-list

    Overdue
    5. [ ] Submit assignment #{today - 1}


    Due Today
    1. [ ] Pay rent
    2. [ ] Service vehicle


    Due Later
    3. [ ] File taxes #{today + 1}
    4. [ ] Call Acme Corp. #{today + 1}
  EXPECTED

  expected_output.strip!

  stripped_output = output.strip.split("\n").map(&:strip).join("\n")

  if stripped_output != expected_output
    diff = Diffy::Diff.new(expected_output, stripped_output)
    @report.add_feedback("add_mismatch", output_and_diff: @report.translate("output_and_diff", output: stripped_output, diff: diff))
  end
rescue => e
  @report.add_feedback("add_error", message_and_backtrace: @report.translate("message_and_backtrace", message: e.message, backtrace: trimmed_backtrace(e.backtrace)))
ensure
  if @report.rejected?
    @report.publish
    exit
  end
end

# Now, let's try to complete some of those tasks.
begin
  _ignored = capture do
    Todo.mark_as_complete(1)
    Todo.mark_as_complete(5)
  end

  output = capture do
    Todo.show_list
  end

  expected_output = <<~EXPECTED
    My Todo-list

    Overdue
    5. [x] Submit assignment #{today - 1}


    Due Today
    1. [x] Pay rent
    2. [ ] Service vehicle


    Due Later
    3. [ ] File taxes #{today + 1}
    4. [ ] Call Acme Corp. #{today + 1}
  EXPECTED

  expected_output.strip!

  stripped_output = output.strip.split("\n").map(&:strip).join("\n")

  unless stripped_output =~ /5\.\s+\[\S\]\s+Submit assignment\s+#{today - 1}.*Due Today.*1\.\s+\[\S\]\s+Pay rent/m
    diff = Diffy::Diff.new(expected_output, stripped_output)
    @report.add_feedback("complete_mismatch", output_and_diff: @report.translate("output_and_diff", output: stripped_output, diff: diff))
  end
rescue => e
  @report.add_feedback("complete_error", message_and_backtrace: @report.translate("message_and_backtrace", message: e.message, backtrace: trimmed_backtrace(e.backtrace)))
else
  @report.add_report("success", output: stripped_output)
  @report.success
ensure
  @report.publish
end
