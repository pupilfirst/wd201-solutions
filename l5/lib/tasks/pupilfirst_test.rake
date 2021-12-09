require "open3"
require_relative "../../../lib/report"

namespace :pupilfirst do
  task :test do
    report = Report.new(File.join(__dir__, "..", ".."))

    stdout, stderr, status = Open3.capture3("bundle exec rails test")

    combined_output = (stdout + "\n" + stderr).strip

    if status == 0
      report.success
      report.add_report("success", output: stdout.strip)
    else
      report.add_feedback("failure", output: combined_output.strip)
    end

    report.publish
  end
end
