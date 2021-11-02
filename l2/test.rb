require "json"
require "open3"
require "../lib/report"

@report = Report.new(__dir__)

def communicate(comm_type, key, command, output)
  command_and_output = @report.translate(:command_and_output, command: command, output: output)
  @report.public_send("add_#{comm_type}", key, command_and_output: command_and_output)
  false
end

def test(command, include:, exclude: false, comm_key:, comm_type: :feedback)
  stdout, stderr, status = Open3.capture3(command)

  if status != 0
    communicate(comm_type, comm_key, command, stderr.strip)
  elsif exclude && stdout.match?(exclude)
    communicate(comm_type, comm_key, command, stdout.strip)
  elsif !stdout.match?(include)
    communicate(comm_type, comm_key, command, stdout.strip)
  else
    true
  end
end

# Check a domain with an A record.
test("ruby lookup.rb ruby-lang.org", include: /ruby-lang.org\s*=>\s*221.186.184.75/, exclude: /error/i, comm_key: "a_record_fail")

# Check a domain with a CNAME.
test("ruby lookup.rb gmail.com", include: /gmail.com\s*=>\s*mail.google.com\s*=>\s*google.com\s*=>\s*172.217.163.46/, exclude: /error/i, comm_key: "cname_record_fail")

# Check a domain that isn't present in the zone file.
test("ruby lookup.rb foo.com", include: /error\S?\s*record\s*not found.*foo.com/i, comm_key: "missing_record_fail")

if @report.rejected?
  @report.add_feedback(:zone_file)
else
  @report.add_report(:critical_tests_passed)

  # Check a CNAME that isn't linked to an A record.
  if test("ruby lookup.rb nowhere.example.com", include: /error\S?\s*record\s*not found.*example.com/i, comm_key: "unlinked_record_fail", comm_type: :report)
    @report.success
  end
end

@report.publish
