require "json"
require "diffy"
require "./setup_db.rb"
require "./todo.rb"

@report = {
  version: 0,
  grade: :skip,
  status: :failure,
  feedback: [],
  report: [],
}

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

def dump_report
  File.write("report.json", JSON.pretty_generate(@report) + "\n")
end

def finalize_if_required
  if @report[:grade] == :reject
    dump_report
    exit
  end
end

# First, try to add some tasks.
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
    @report[:grade] = :reject
    @report[:feedback] << { key: "add_mismatch", variables: { output: stripped_output, diff: diff } }
  end
rescue => e
  @report[:grade] = :reject
  @report[:feedback] << { key: "add_error", variables: { message: e.message, backtrace: e.backtrace.join("\n") } }
ensure
  finalize_if_required
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
    @report[:grade] = :reject
    @report[:feedback] << { key: "complete_mismatch", variables: { output: stripped_output, diff: diff } }
  end
rescue => e
  @report[:grade] = :reject
  @report[:feedback] << { key: "complete_error", variables: { message: e.message, backtrace: e.backtrace.join("\n") } }
else
  @report[:status] = :success
  @report[:report] << { key: "success", variables: { output: stripped_output } }
ensure
  dump_report
end
