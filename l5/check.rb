puts __dir__
j = File.join(__dir__, '..', '..')
puts j
puts File.absolute_path(j)
puts File.absolute_path(__dir__)
