require 'test/unit'
require 'rubygems'
require 'mocha'
require 'migrate_fixtures'

class MigrateFixturesTest < Test::Unit::TestCase

  def setup
    @migrator = MigrateFixtures.new
    @yaml = {"two"=>{"name"=>"MyString", "id"=>"2"}, "one"=>{"name"=>"MyString", "id"=>"1"}}
  end

def test_fail
    flunk("))<<>>((")
  end

  def test_gather_fixture_names_so_we_can_remember_what_the_fixtures_were_called
    name_hash = @migrator.gather_fixture_names("table_name", @yaml)
    assert_equal(@yaml.keys.first, name_hash["2"])
    assert_equal(@yaml.keys.last, name_hash["1"])
  end
  
  def test_gather_fixture_names_puts_schema_info_fixture_name_into_hash_with_nil_as_the_key
    name_hash = @migrator.gather_fixture_names("schema_info", @yaml)
    assert_equal(1, name_hash.size)
    assert_equal(@yaml.keys.first, name_hash[nil])
  end
  
  def test_grabbing_comment_from_top_of_file_when_there_is_a_comment
    comment = "# Read about fixtures at http://ar.rubyonrails.org/classes/Fixtures.html\n"
    filename = "jobs.yml"
    mock_filesys = Filesystem.new
    mock_filesys.expects(:file_to_array).with(filename).returns([comment, "one:\n", "name: MyString\n", "id: \"1\"\n"])
    @migrator.filesys = mock_filesys
    assert_equal(comment, @migrator.grab_comment_from_top_of_file(filename))
  end
  
  def test_grabbing_comment_from_top_of_file_when_there_is_a_multi_line_comment
    comment = "# Read about fixtures at http://ar.rubyonrails.org/classes/Fixtures.html\n"
    comment_two = "# No Funny Business\n"
    filename = "jobs.yml"
    mock_filesys = Filesystem.new
    mock_filesys.expects(:file_to_array).with(filename).returns([comment, comment_two, "one:\n", "name: MyString\n", "id: \"1\"\n"])
    @migrator.filesys = mock_filesys
    assert_equal(comment + comment_two, @migrator.grab_comment_from_top_of_file(filename))
  end
  
  def test_grabbing_comment_from_top_of_file_when_there_is_not_a_comment
    filename = "jobs.yml"
    mock_filesys = Filesystem.new
    mock_filesys.expects(:file_to_array).with(filename).returns(["one:\n", "name: MyString\n", "id: \"1\"\n"])
    @migrator.filesys = mock_filesys
    assert_equal("", @migrator.grab_comment_from_top_of_file(filename))
  end
  
  def test_get_current_fixture_version_works
    schema_info_fixture = "./test/fixtures/schema_info.yml"
    schema_info_yaml = {"blarg"=>{"version"=>"1"}}
    mock_filesys = Filesystem.new
    mock_filesys.expects(:load_yaml).with("./test/fixtures/schema_info.yml").returns(schema_info_yaml)
    @migrator.filesys = mock_filesys
    assert_equal(1, @migrator.get_current_fixture_version(schema_info_fixture))
  end
  
  def test_converting_database_to_fixtures
    #this test isn't a unit test... 
    #turns out this method must not be good because it is hard to test
    #However i feel better just exercizing some code anyway. Thanks mocha.
    fixtures_path = "."
    mock_filesys = Filesystem.new
    mock_filesys.expects(:database_tables).returns(["jobs"])
    mock_filesys.expects(:exists?).with("./jobs.yml").returns(true)
    mock_filesys.expects(:load_yaml).with("./jobs.yml").returns(@yaml)
    @migrator.filesys = mock_filesys
    @migrator.expects(:write_fixture_to_file).returns(true)
    @migrator.expects(:grab_comment_from_top_of_file).returns("# a comment\n")
    @migrator.expects(:gather_fixture_names).returns(["one", "two"])
    @migrator.dump_database_to_fixtures(fixtures_path)
  end
end
