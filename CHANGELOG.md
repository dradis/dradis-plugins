## Dradis Framework 3.8 (XXX, 2017) ##

* ContentService#all_properties now pulls the Report Content document properties

## Dradis Framework 3.7 (XXX, 2017) ##

*   Add ContentService#all_properties method to access the current project's
    properties.

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
