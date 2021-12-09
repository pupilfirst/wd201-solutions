require "yaml"
require "active_support/all"

class Report
  def initialize(dir)
    @dir = File.absolute_path(dir)

    @report = {
      version: 0,
      grade: :skip,
      status: :failure,
      feedback: "",
      report: "",
    }
  end

  def skipped?
    @report[:grade] == :skip
  end

  def rejected?
    @report[:grade] == :reject
  end

  def success
    @report[:status] = :success
  end

  def add_feedback(key, variables = {})
    @report[:feedback] = old_text(@report[:feedback]) + translate(key, variables)
    @report[:grade] = :reject
  end

  def add_report(key, variables = {})
    @report[:report] = old_text(@report[:report]) + translate(key, variables)
  end

  def publish
    File.write(File.expand_path("./report.json", @dir), JSON.pretty_generate(@report) + "\n")

    unless ENV["VTA_ENV"] == "production"
      if @report[:feedback].present?
        STDOUT.puts "## Test Results\n\n"
        STDOUT.puts @report[:feedback]
      end

      if @report[:report].present?
        STDOUT.puts "## Test Report\n\n"
        STDOUT.puts @report[:report]
      end
    end
  end

  def translate(key, variables = {})
    translation = translations[key]

    raise "Could not find translation for key '#{key}'" if translation.blank?

    translation % variables
  end

  private

  def old_text(text)
    if text.present?
      text + "\n\n---\n\n"
    else
      text
    end
  end

  def translations
    @translations ||= begin
        en_path = File.expand_path("./en.yml", @dir)
        YAML.load_file(en_path).with_indifferent_access
      end
  end
end
