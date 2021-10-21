require 'json'
require 'open3'
require 'date'
require 'diffy'

@report = {
  version: 0,
  grade: :skip,
  status: :failure,
  feedback: [],
  report: []
}

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

stdout, stderr, status = Open3.capture3('ruby todo_list.rb')

stripped_output = stdout.strip.split("\n").map(&:strip).join("\n")

if status != 0
  @report[:grade] = :reject
  @report[:feedback] << { key: 'execution_error', variables: { output: stderr.strip }}
elsif stripped_output == expected_output
  @report[:status] = :success
  @report[:report] << { key: 'success', variables: { output: stripped_output }}
else
  @report[:grade] = :reject
  diff = Diffy::Diff.new(expected_output, stripped_output)
  puts diff
  @report[:feedback] << { key: 'output_mismatch', variables: { output: stripped_output, diff: diff }}
end

File.write('report.json', JSON.pretty_generate(@report) + "\n")
