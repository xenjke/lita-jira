require 'lita'
require 'jira'

module Lita
  module Handlers
    class Jira < Handler
      ISSUE_ID_MATCH = '([a-zA-Z]{2,4}-\d*)'

      route(
        /^jira\s#{ISSUE_ID_MATCH}$/,
        :issue_summary,
        command: true,
        help: { 'jira <issue ID>' => 'Shows basic details on <issue ID>' }
      )

      route(
        /^jira\sdetails\s#{ISSUE_ID_MATCH}$/,
        :issue_details,
        command: true,
        help: { 'jira details <issue ID>' => 'Shows all details on <issue ID>' }
      )

      route(
        /^jira\s(\D*)\s"(.+)"$/,
        :issue_create,
        command: true,
        help: { 'jira <project key> "<summary>"' => 'Creates a new issue with <summary> in <project key>'}
      )

      route(
        /^jira\snew\sissue\s(\D*)\s"(.+)"$/,
        :issue_create,
        command: true,
        help: { 'jira new issue <project key> "<summary>"' => 'Creates a new issue with <summary> in <project key>' }
      )

      route(
        /^jira\s#{ISSUE_ID_MATCH}\s"(.+)"$/,
        :comment_create,
        command: true,
        help: { '' => '' }
      )

      route(
        /^jira\snew\scomment\s#{ISSUE_ID_MATCH}\s"(.+)"$/,
        :comment_create,
        command: true,
        help: { '' => '' }
      )

      def self.default_config(config)
        config.username = nil
        config.password = nil
        config.site     = nil
        config.context  = nil
      end

      def issue_summary(response)
        key = response.matches[0][0]
        issue = fetch_issue(key)
        if issue
          response.reply("#{key}: #{issue.summary}")
        else
          response.reply('Error fetching JIRA issue')
        end
      end

      def issue_details(response)
        key = response.matches[0][0]
        issue = fetch_issue(key)
        if issue
          response.reply("#{key}: #{issue.summary}, " \
                         "assigned to: #{issue.assignee.displayName}, " \
                         "priority: #{issue.priority.name}, " \
                         "status: #{issue.status.name}")
        else
          response.reply('Error fetching JIRA issue')
        end
      end

      def issue_create(response)
        project_id = response.matches[0][0]
        summary = response.matches[0][1]
        issue_id = create_issue(project_id, summary)
        if issue_id
          response.reply("Created issue #{issue_id}")
        else
          response.reply('Error creating JIRA issue')
        end
      end

      def comment_create(response)
      end

      private

      def j_client
        return if Lita.config.handlers.jira.username.nil? ||
                  Lita.config.handlers.jira.password.nil? ||
                  Lita.config.handlers.jira.site.nil?     ||
                  Lita.config.handlers.jira.context.nil?

        options = {
          username:      Lita.config.handlers.jira.username,
          password:      Lita.config.handlers.jira.password,
          site:          Lita.config.handlers.jira.site,
          context_path:  Lita.config.handlers.jira.context,
          auth_type:     :basic
        }

        JIRA::Client.new(options)
      end

      def fetch_issue(key)
        client = j_client
        if client
          begin
            client.Issue.find(key)
          rescue JIRA::HTTPError
            nil
          end
        end
      end

      def create_issue(project_id, summary)
        nil
#        client = j_client
#        if client
#          begin
#            client.Issue.new(project_id, summary)
#          rescue JIRA::HTTPError
#            nil
#          end
#        end
      end
    end

    Lita.register_handler(Jira)
  end
end

Lita.load_locales Dir[File.expand_path(
  File.join('..', '..', '..', '..', 'locales', '*.yml'), __FILE__
)]
