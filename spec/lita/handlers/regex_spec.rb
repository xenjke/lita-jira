require 'spec_helper'

describe Lita::Handlers::JiraUtility, lita_handler: true do
  let(:project_pattern) { JiraHelper::Regex::PROJECT_PATTERN }
  let(:subject_pattern) { JiraHelper::Regex::SUBJECT_PATTERN }
  let(:summary_pattern) { JiraHelper::Regex::SUMMARY_PATTERN }
  let(:regex) { Regexp.new(/^todo\s#{project_pattern}\s#{subject_pattern}(\s#{summary_pattern})?$/) }

  it 'double qoutes around subject and summary' do
    match = %(todo PRJ "Any subject" "Any summary").match(regex)
    expect(match['project']).to eq('PRJ')
    expect(match['summary']).to eq('Any summary')
    expect(match['subject']).to eq('Any subject')
  end
end
