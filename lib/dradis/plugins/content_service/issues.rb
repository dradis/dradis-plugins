module Dradis::Plugins::ContentService
  module Issues
    extend ActiveSupport::Concern

    def all_issues
      project.issues.where(category_id: default_issue_category.id)
    end

    def create_issue(args={})
      text = args.fetch(:text, default_issue_text)
      # NOTE that ID is the unique issue identifier assigned by the plugin,
      # and is not to be confused with the Issue#id primary key
      id   = args.fetch(:id, default_issue_id)

      # Bail if we already have this issue in the cache
      uuid      = [plugin::Engine::plugin_name, id]
      cache_key = uuid.join('-')

      return issue_cache[cache_key] if issue_cache.key?(cache_key)

      # we inject the source Plugin and unique ID into the issue's text
      plugin_details =
        "\n\n#[plugin]#\n#{uuid[0]}\n" \
        "\n\n#[plugin_id]#\n#{uuid[1]}\n"
      text << plugin_details

      issue = Issue.new(text: text) do |i|
        i.author   = default_author
        i.node     = project.issue_library
        i.category = default_issue_category
      end

      if issue.valid?
        issue.save
      else
        try_rescue_from_length_validation(
          model: issue,
          field: :text,
          text: text,
          msg: 'Error in create_issue()',
          tail: plugin_details
        )
      end

      issue_cache.store(cache_key, issue)
    end

    def create_many_issues(issues)
      new_issues = []

      issues.each do |issue|
        issue[:text] = default_issue_text if issue[:text].blank?
        # NOTE that ID is the unique issue identifier assigned by the plugin,
        # and is not to be confused with the Issue#id primary key
        issue[:id] = default_issue_id if issue[:id].blank?

        uuid      = [plugin::Engine::plugin_name, issue[:id]]
        cache_key = uuid.join('-')
        next if issue_cache.key?(cache_key)

        # skip dups
        next if new_issues.map { |i| i[:id] }.include?(issue[:id])

        # we inject the source Plugin and unique ID into the issue's text
        plugin_details =
          "\n\n#[plugin]#\n#{uuid[0]}\n" \
          "\n\n#[plugin_id]#\n#{uuid[1]}\n"
        issue[:text] << plugin_details

        # TODO: check issue text length

        new_issues << issue
      end

      return false if new_issues.empty?

      node_id = project.issue_library.id
      time = Time.now.strftime('%Y-%m-%d %H:%M:%S')
      values = new_issues.map{ |issue| "('#{default_author}', #{default_issue_category.id}, '#{time}', #{node_id}, #{ActiveRecord::Base.connection.quote(issue[:text])}, '#{time}')" }.join(',')
      sql = "INSERT INTO notes (author, category_id, created_at, node_id, text, updated_at) VALUES #{values}"
      ActiveRecord::Base.connection.execute(sql)

      all_issues.each do |issue|
        issue_plugin_id = issue.fields['plugin_id']
        uuid      = [plugin::Engine::plugin_name, issue_plugin_id]
        cache_key = uuid.join('-')
        issue_cache.store(cache_key, issue)
      end
    end

    # Create a hash with all issues where the keys correspond to the field passed
    # as an argument.
    #
    # This is use by the plugins to check whether a given issue is already in
    # the project.
    # def all_issues_by_field(field)
    #   # we don't memoize it because we want it to reflect recently added Issues
    #   klass = class_for(:issue)
    #
    #   issues_map = klass.where(category_id: default_issue_category.id).map do |issue|
    #     [issue.fields[field], issue]
    #   end
    #   Hash[issues_map]
    # end

    # Accesing the library by primary sorting key. Raise an exception unless
    # the issue library cache has been initialized.
    def issue_cache
      @issue_cache ||= begin
        issues_map = all_issues.map do |issue|
          cache_key = [
            issue.fields['plugin'],
            issue.fields['plugin_id']
          ].join('-')

          [cache_key, issue]
        end
        Hash[issues_map]
      end
    end


    private

    def default_issue_category
      @default_issue_category ||= Category.issue
    end

    def default_issue_id
      "create_issue() invoked by #{plugin} without an :id parameter"
    end

    def default_issue_text
      "create_issue() invoked by #{plugin} without a :text parameter"
    end
  end
end
