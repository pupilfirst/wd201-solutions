require 'json'
require 'open3'

@report = {
  version: 0,
  grade: :skip,
  status: :failure,
  feedback: [],
  report: []
}

def test(command, include:, exclude: false, comm_key:, comm_type: :feedback, grade: :reject)
  stdout, stderr, status = Open3.capture3(command)

  if status != 0
    @report[:grade] = grade
    @report[comm_type] << { key: comm_key, variables: { response: stderr.strip } }
  elsif exclude && stdout.match?(exclude)
    @report[:grade] = grade
    @report[comm_type] << { key: comm_key, variables: { response: stdout.strip } }
  elsif !stdout.match?(include)
    @report[:grade] = grade
    @report[comm_type] << { key: comm_key, variables: { response: stdout.strip } }
  end
end

# Check a domain with an A record.
test('ruby lookup.rb ruby-lang.org', include: /ruby-lang.org\s*=>\s*221.186.184.75/, exclude: /error/i, comm_key: 'a_record_fail')

# Check a domain with a CNAME.
test('ruby lookup.rb gmail.com', include: /gmail.com\s*=>\s*mail.google.com\s*=>\s*google.com\s*=>\s*172.217.163.46/, exclude: /error/i, comm_key: 'cname_record_fail')

# Check a domain that isn't present in the zone file.
test('ruby lookup.rb foo.com', include: /error\S?\s*record\s*not found.*foo.com/i, comm_key: 'missing_record_fail')

if @report[:grade] == :skip
  @report[:report] << { key: 'critical_tests_passed' }

  # Check a CNAME that isn't linked to an A record.
  test('ruby lookup.rb nowhere.example.com', include: /error\S?\s*record\s*not found.*example.com/i, comm_key: 'unlinked_record_fail', comm_type: :report, grade: :skip)

  if @report[:report].length == 1
    @report[:status] = :success
  end
end

File.write('report.json', JSON.pretty_generate(@report) + "\n")
