require 'json'
require 'open3'

@report = {
  version: 0,
  reject: false,
  accept: false,
  communication: [],
}

def test(command, matcher:, comm_key:, comm_type: :feedback, reject: true)
  stdout, stderr, status = Open3.capture3(command)

  if status != 0
    @report[:reject] = reject
    @report[:communication] << { type: comm_type, key: comm_key, locals: { response: stderr.strip } }
  elsif !stdout.match?(matcher)
    @report[:reject] = reject
    @report[:communication] << { type: comm_type, key: comm_key, locals: { response: stdout.strip } }
  end
end

# Check a domain with an A record.
test('ruby lookup.rb ruby-lang.org', matcher: /ruby-lang.org\s*=>\s*221.186.184.75/, comm_key: 'a_record_fail')

# Check a domain with a CNAME.
test('ruby lookup.rb gmail.com', matcher: /gmail.com\s*=>\s*mail.google.com\s*=>\s*google.com\s*=>\s*172.217.163.46/, comm_key: 'cname_record_fail')

# Check a domain that isn't present in the zone file.
test('ruby lookup.rb foo.com', matcher: /error\S?\s*record\s*not found.*foo.com/i, comm_key: 'missing_record_fail')

unless @report[:reject]
  @report[:communication] << { type: :report, key: 'critical_tests_passed' }
end

# Check a CNAME that isn't linked to an A record.
test('ruby lookup.rb nowhere.example.com', matcher: /error\S?\s*record\s*not found.*example.com/i, comm_key: 'unlinked_record_fail', comm_type: :report, reject: false)

File.write('report.json', JSON.pretty_generate(@report) + "\n")
