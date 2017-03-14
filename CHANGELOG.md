## Dradis Framework 3.6 (March XX, 2017) ##

*   Split the ContentService into multiple modules.

*   Abandon home-grown configuration in favor of `Rails.application.config`.

*   An instance of ContentService and TemplateService is created for all
    plugins from this layer removing the need for plugin authors to create
    their own.

*   The Export / Upload base classes attempt to auto-detect the plugin module
    (if it isn't passed as a :plugin parameter.
