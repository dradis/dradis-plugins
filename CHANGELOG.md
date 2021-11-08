v4.1.0 (November 2021)
  - No changes

v4.0.0 (July 2021)
  - No changes

v3.22.0 (April 2021)
  - ContentService#create_evidence: deduplicate Evidence from integrations

v3.21.0 (February 2021)
  - Rename `parent` methods to `module_parent` as `Module#parent` is deprecated

v3.20.0 (January 2021)
  - No changes

v3.19.0 (September 2020)
  - No changes

v3.18.0 (July 2020)
  - Added PersistentPermissions module to dry up permissions endpoints

v3.17.0 (May 2020)
  - No changes

v3.16.0 (February 2020)
  - No changes

v3.15.0 (November 2019)
  - No changes

v3.14.0 (August 2019)
  - No changes

v3.13.0 (June 2019)
  - No changes

v3.12.0 (March 2019)
  - No changes

v3.11.0 (November 2018)
  - No changes

v3.10.1 (November 2018)
  - Do not use `Node#project_id`

v3.10.0 (August 2018)
  - Add default project to task options
  - Avoid requiring the caller to use `set_project_scope`
  - Default title sorting for content blocks
  - Use AuthenticatedController as export base

v3.9.0 (January 2018)
  - No changes

v3.8.0 (September 2017)
  - Add ContentService#all_content_blocks method to access the current project's content blocks
  - Add ContentService#create_content_blocks method to create content blocks with
  - Add default_user_id attribute to the importer

v3.7.0 (July 2017)
  - Add ContentService#all_properties method to access the current project's document properties
  - Don't lose :plugin and :plugin_id from ContentService#create_issue due to excessive input length

v3.6.0 (April 2016)
  - Abandon home-grown configuration in favor of `Rails.application.config`
  - An instance of ContentService and TemplateService is created for all plugins from this layer removing the need for plugin authors to create their own
  - Split the ContentService into multiple modules
  - The Export / Upload base classes attempt to auto-detect the plugin module (if it isn't passed as a :plugin parameter)
