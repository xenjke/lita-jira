require 'spec_helper'

describe Lita::Handlers::Jira, lita_handler: true do
  it { routes_command('jira ABC "short summary"').to(:issue_create) }
  it { routes_command('jira ABC-123 "additional comment"').to(:comment_create) }
  it { routes_command('jira ABC-123').to(:issue_summary) }
  it { routes_command('jira new issue ABC "Short summary"').to(:issue_create) }
  it { routes_command('jira new comment ABC-123 "additional comment"').to(:comment_create) }
  it { routes_command('jira details ABC-123').to(:issue_details) }

  describe '.default_config' do
    it 'sets username to nil' do
      expect(Lita.config.handlers.jira.username).to be_nil
    end

    it 'sets password to nil' do
      expect(Lita.config.handlers.jira.password).to be_nil
    end

    it 'sets site to nil' do
      expect(Lita.config.handlers.jira.site).to be_nil
    end

    it 'sets context to nil' do
      expect(Lita.config.handlers.jira.context).to be_nil
    end
  end

  describe '#issue_summary' do
    it 'with valid issue ID shows summary' do
      response = double(summary: 'Some summary text')
      allow_any_instance_of(Lita::Handlers::Jira).to \
        receive(:fetch_issue).with('XYZ-987').and_return(response)
      send_command('jira XYZ-987')
      expect(replies.last).to eq('XYZ-987: Some summary text')
    end

    it 'without valid issue ID shows an error' do
      allow_any_instance_of(Lita::Handlers::Jira).to \
        receive(:fetch_issue).with('XYZ-987').and_return(nil)
      send_command('jira XYZ-987')
      expect(replies.last).to eq('Error fetching JIRA issue')
    end
  end

  describe '#issue_details' do
    it 'with valid issue ID shows details' do
      response = double(summary: 'Some summary text',
                        assignee: double(displayName: 'A Person'),
                        priority: double(name: 'P0'),
                        status: double(name: 'In Progress'))
      allow_any_instance_of(Lita::Handlers::Jira).to \
        receive(:fetch_issue).with('XYZ-987').and_return(response)
      send_command('jira XYZ-987 details')
      expect(replies.last).to eq('XYZ-987: Some summary text, assigned to: ' \
                                 'A Person, priority: P0, status: In Progress')
    end

    it 'without valid issue ID shows an error' do
      allow_any_instance_of(Lita::Handlers::Jira).to \
        receive(:fetch_issue).with('XYZ-987').and_return(nil)
      send_command('jira XYZ-987 details')
      expect(replies.last).to eq('Error fetching JIRA issue')
    end
  end

  describe '#issue_create' do
    it 'with valid project ID and summary creates an issue' do
      allow_any_instance_of(Lita::Handlers::Jira).to \
        receive(:create_issue).with('XYZ', 'Short summary').and_return('XYZ-001')
      send_command('jira new issue XYZ "Short summary"')
      expect(replies.last).to eq('Created issue XYZ-001')
    end

    it 'without a valid project ID shows an error' do
      allow_any_instance_of(Lita::Handlers::Jira).to \
       receive(:create_issue).with('INVALID', 'Short summary').and_return(nil)
      send_command('jira new INVALID "Short summary"')
      expect(replies.last).to eq('Error creating JIRA issue')
    end
  end
end
