## Dradis Framework 3.16 (February, 2020) ##

*  No changes.

## Dradis Framework 3.15 (November, 2019) ##

*  Make ContentService Boards available in CE

## Dradis Framework 3.14 (August, 2019) ##

*  Add node to boards

## Dradis Framework 3.13 (June, 2019) ##

*  No changes.

## Dradis Framework 3.12 (March, 2019) ##

*  No changes.

## Dradis Framework 3.11 (November, 2018) ##

*  No changes.

## Dradis Framework 3.10.1 (November, 2018) ##

*  Do not use `Node#project_id`

## Dradis Framework 3.10 (August, 2018) ##

*  Add default project to task options
*  Use AuthenticatedController as export base
*  Default title sorting for content blocks
*  Avoid requiring the caller to use `set_project_scope`

## Dradis Framework 3.9 (January, 2018) ##

*  No changes

## Dradis Framework 3.8 (September, 2017) ##

*   Add ContentService#all_content_blocks method to access the current project's
    content blocks.

*   Add ContentService#create_content_blocks method to create content blocks
    with.

*   Add default_user_id attribute to the importer.

## Dradis Framework 3.7 (July, 2017) ##

*   Add ContentService#all_properties method to access the current project's
    document properties.

*   Don't lose :plugin and :plugin_id from ContentService#create_issue due to
    excessive input length.

## Dradis Framework 3.6 (April 6, 2017) ##

*   Split the ContentService into multiple modules.

*   Abandon home-grown configuration in favor of `Rails.application.config`.

*   An instance of ContentService and TemplateService is created for all
    plugins from this layer removing the need for plugin authors to create
    their own.

*   The Export / Upload base classes attempt to auto-detect the plugin module
    (if it isn't passed as a :plugin parameter.
