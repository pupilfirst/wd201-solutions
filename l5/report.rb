require "../lib/report"
data = File.read("./test_result.txt")

@report = Report.new(__dir__)

expected_output = <<~OUTPUT
7 runs, 40 assertions, 0 failures, 0 errors, 0 skips
OUTPUT

if data.empty?
  @report.add_report("failure", output: 'VTA failed to run test on the given repo.')
elsif data.split("\n").last.strip == expected_output.strip
  @report.add_report("success", output: data)
  @report.success
else
  @report.add_report("failure", output: data)
end

@report.publish
