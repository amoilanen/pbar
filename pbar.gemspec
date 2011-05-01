# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{pbar}
  s.version = "0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Anton Ivanov"]
  s.date = %q{2011-05-01}
  s.description = %q{Progress tracking command line utilities}
  s.email = %q{anton.al.ivanov@gmail.com}
  s.extra_rdoc_files = ["README", "lib/pbar/progress_bar.rb"]
  s.files = ["README", "Rakefile", "lib/pbar/progress_bar.rb", "test/progress_bar_test.rb", "Manifest", "pbar.gemspec"]
  s.homepage = %q{https://github.com/antivanov/pbar}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Pbar", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{pbar}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Progress tracking command line utilities}
  s.test_files = ["test/progress_bar_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
