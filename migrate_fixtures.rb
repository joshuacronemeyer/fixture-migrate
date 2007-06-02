class MigrateFixtures

  attr_accessor :filesys
  
  def initialize()
    @filesys = Filesystem.new
  end
  
  def dump_database_to_fixtures(fixtures_path)
    @filesys.database_tables.each do |table_name|
      yaml_file_name = "#{fixtures_path}/#{table_name}.yml"
      if (@filesys.exists?(yaml_file_name))
        yaml = @filesys.load_yaml(yaml_file_name)
        fixture_names = gather_fixture_names(table_name, yaml)
        top_of_file_comment = grab_comment_from_top_of_file(yaml_file_name)
        write_fixture_to_file(table_name, yaml_file_name, fixture_names, top_of_file_comment)
      end
    end
  end
  
  def gather_fixture_names(table_name, source_yaml)
    fixture_names = Hash.new
    if (table_name != "schema_info")
      source_yaml.keys.each { |key| fixture_names[source_yaml[key]["id"].to_s] = key}
    else
      fixture_names[nil] = source_yaml.keys.first
    end
    return fixture_names
  end
  
  def grab_comment_from_top_of_file(yaml_file_name)
    lines = @filesys.file_to_array(yaml_file_name)
    comments = ""
    lines.each{|line| comments << line unless !(/^#/ =~ line)}
    return comments
  end
  
  def write_fixture_to_file(source_table_name, destination_file_name, fixture_names, top_of_file_comment)
    sql  = 'SELECT * FROM %s'
    File.open(destination_file_name, File::RDWR|File::TRUNC|File::CREAT) do |file|
      file.write(top_of_file_comment)
      #TODO extract this little inject loop so we can test it seperately.  The rest of this method isn't worth testing.
      table = ActiveRecord::Base.connection.select_all(sql %source_table_name).inject({}) do |hash, record|
        hash[fixture_names[record["id"]]] = record
        hash
      end
      file.write(table.to_yaml)
    end
  end
  
  def delete_fixtures(fixtures_path, deleted_tables)
    deleted_tables.each{|table_name| File.delete("#{fixtures_path}/#{table_name}.yml") if File.exists?("#{fixtures_path}/#{table_name}.yml")}  
  end
  
  def get_current_fixture_version(schema_info_fixture)
    yaml = @filesys.load_yaml(schema_info_fixture)
    return yaml[(yaml.keys.first)]["version"].to_i
  end
  
end
  
  #silly class to wrap up all the hard-to-test-stuff so we can easily mock it.
  class Filesystem
    def exists?(filename)
      return File.exists?(filename)
    end
    
    def load_yaml(filename)
      return YAML::load_file(filename)
    end
    
    def database_tables
      return ActiveRecord::Base.connection.tables
    end
    
    def file_to_array(filename)
      lines = []
      File.open(filename, 'r') do |file|
        file.each_line do |line|
          lines << line
        end
      end
      return lines
    end
    
  end