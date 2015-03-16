## Assumptions: ##
  1. You are working with a rails application.
  1. You only have fixture files for tables in your database.  That is if you have a table called companies you have a fixture called companies.yml.

## Usage ##
To add this rake task to your project just drop the migrate\_fixtures.rake and migrate\_fixtures.rb files into the lib/tasks directory of your rails project.  Create a schema\_info.yaml file under test/fixtures that contains something like the following:
```
schema_info: 
  version: "2"
```
version number must correspond to the version of your database that your fixtures are currently at.

Now to try it out add a new migration to your project.  After calling the db migration you can call `rake db:fixtures:migrate` and the same migration will be run on your fixtures.
