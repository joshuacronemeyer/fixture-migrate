task :default => [:test]
task :cruise => [:test]
task :test do |t|
  test_files = FileList['*test*']
	test_files.each{|file| system("ruby #{file}")}
end
