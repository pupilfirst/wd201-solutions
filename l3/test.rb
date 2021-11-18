require "json"
require "open3"
require "date"
require "diffy"
require "../lib/report"

@report = Report.new(__dir__)

today = Date.today

expected_output = <<~OUTPUT
  My Todo-list

  Overdue
  [ ] Submit assignment #{today - 1}


  Due Today
  [x] Pay rent
  [ ] Service vehicle


  Due Later
  [ ] File taxes #{today + 1}
  [ ] Call Acme Corp. #{today + 1}
OUTPUT

expected_output.strip!

stdout, stderr, status = Open3.capture3("ruby todo_list.rb")

stripped_output = stdout.strip.split("\n").map(&:strip).join("\n")

if status != 0
  @report.add_feedback("execution_error", output: stderr.strip)
elsif stripped_output == expected_output
  @report.add_report("success", output: stripped_output)
  @report.success
else
  diff = Diffy::Diff.new(expected_output, stripped_output)
  @report.add_feedback("output_mismatch", output: stripped_output, diff: diff)
end

@report.publish
