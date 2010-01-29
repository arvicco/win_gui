# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{win_gui}
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["arvicco"]
  s.date = %q{2010-01-29}
  s.description = %q{Rubyesque interfaces and wrappers for Win32 API GUI functions}
  s.email = %q{arvitallian@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "book_code/early_success/bundle.rb",
     "book_code/early_success/english.txt",
     "book_code/early_success/jruby_basics.rb",
     "book_code/early_success/windows_basics.rb",
     "book_code/guessing/locknote.rb",
     "book_code/guessing/monkeyshines.rb",
     "book_code/guessing/note.rb",
     "book_code/guessing/note_spec.rb",
     "book_code/guessing/replay.rb",
     "book_code/guessing/seed.rb",
     "book_code/guessing/spec_helper.rb",
     "book_code/guessing/windows_gui.rb",
     "book_code/home_stretch/junquenote.rb",
     "book_code/home_stretch/locknote.rb",
     "book_code/home_stretch/note.rb",
     "book_code/home_stretch/note_spec.rb",
     "book_code/home_stretch/spec_helper.rb",
     "book_code/home_stretch/swing_gui.rb",
     "book_code/home_stretch/windows_gui.rb",
     "book_code/junquenote/exports.sh",
     "book_code/junquenote/jruby_mac.sh",
     "book_code/junquenote/junquenote_app.rb",
     "book_code/novite/Rakefile",
     "book_code/novite/app/controllers/application.rb",
     "book_code/novite/app/controllers/guests_controller.rb",
     "book_code/novite/app/controllers/parties_controller.rb",
     "book_code/novite/app/helpers/application_helper.rb",
     "book_code/novite/app/helpers/guests_helper.rb",
     "book_code/novite/app/helpers/parties_helper.rb",
     "book_code/novite/app/models/guest.rb",
     "book_code/novite/app/models/party.rb",
     "book_code/novite/app/models/party_mailer.rb",
     "book_code/novite/app/views/layouts/application.rhtml",
     "book_code/novite/app/views/parties/new.html.erb",
     "book_code/novite/app/views/parties/show.html.erb",
     "book_code/novite/app/views/party_mailer/invite.erb",
     "book_code/novite/config/boot.rb",
     "book_code/novite/config/database.yml",
     "book_code/novite/config/environment.rb",
     "book_code/novite/config/environments/development.rb",
     "book_code/novite/config/environments/production.rb",
     "book_code/novite/config/environments/test.rb",
     "book_code/novite/config/initializers/inflections.rb",
     "book_code/novite/config/initializers/mime_types.rb",
     "book_code/novite/config/routes.rb",
     "book_code/novite/db/migrate/001_create_parties.rb",
     "book_code/novite/db/migrate/002_create_guests.rb",
     "book_code/novite/db/schema.rb",
     "book_code/novite/log/empty.txt",
     "book_code/novite/public/.htaccess",
     "book_code/novite/public/404.html",
     "book_code/novite/public/422.html",
     "book_code/novite/public/500.html",
     "book_code/novite/public/dispatch.cgi",
     "book_code/novite/public/dispatch.fcgi",
     "book_code/novite/public/dispatch.rb",
     "book_code/novite/public/favicon.ico",
     "book_code/novite/public/images/rails.png",
     "book_code/novite/public/index.html",
     "book_code/novite/public/javascripts/application.js",
     "book_code/novite/public/javascripts/controls.js",
     "book_code/novite/public/javascripts/dragdrop.js",
     "book_code/novite/public/javascripts/effects.js",
     "book_code/novite/public/javascripts/prototype.js",
     "book_code/novite/public/robots.txt",
     "book_code/novite/script/about",
     "book_code/novite/script/console",
     "book_code/novite/script/destroy",
     "book_code/novite/script/generate",
     "book_code/novite/script/performance/benchmarker",
     "book_code/novite/script/performance/profiler",
     "book_code/novite/script/performance/request",
     "book_code/novite/script/plugin",
     "book_code/novite/script/process/inspector",
     "book_code/novite/script/process/reaper",
     "book_code/novite/script/process/spawner",
     "book_code/novite/script/runner",
     "book_code/novite/script/server",
     "book_code/novite/test/test_helper.rb",
     "book_code/one_more_thing/applescript.rb",
     "book_code/one_more_thing/note_spec.rb",
     "book_code/one_more_thing/spec_helper.rb",
     "book_code/one_more_thing/textedit-pure.rb",
     "book_code/one_more_thing/textedit.applescript",
     "book_code/one_more_thing/textedit.rb",
     "book_code/one_more_thing/textnote.rb",
     "book_code/simplify/junquenote.rb",
     "book_code/simplify/locknote.rb",
     "book_code/simplify/note.rb",
     "book_code/simplify/note_spec.rb",
     "book_code/simplify/swing_gui.rb",
     "book_code/simplify/windows_gui.rb",
     "book_code/simplify/windows_gui_spec.rb",
     "book_code/story/invite.story",
     "book_code/story/journal.txt",
     "book_code/story/novite_stories.rb",
     "book_code/story/party.rb",
     "book_code/story/password.rb",
     "book_code/story/password.story",
     "book_code/story/rsvp.story",
     "book_code/tables/TestTime.html",
     "book_code/tables/TestTimeSample.html",
     "book_code/tables/calculate_time.rb",
     "book_code/tables/calculator.rb",
     "book_code/tables/calculator_actions.rb",
     "book_code/tables/calculator_spec.rb",
     "book_code/tables/fit.rb",
     "book_code/tables/matrix.rb",
     "book_code/tables/pseudocode.rb",
     "book_code/tubes/book_selenium.rb",
     "book_code/tubes/book_watir.rb",
     "book_code/tubes/dragdrop.html",
     "book_code/tubes/html_capture.rb",
     "book_code/tubes/joke_list.rb",
     "book_code/tubes/list_spec.rb",
     "book_code/tubes/search_spec.rb",
     "book_code/tubes/selenium_example.rb",
     "book_code/tubes/selenium_link.rb",
     "book_code/tubes/web_server.rb",
     "book_code/windows/wgui.rb",
     "book_code/windows/wobj.rb",
     "book_code/windows/wsh.rb",
     "book_code/with_rspec/empty_spec.rb",
     "book_code/with_rspec/junquenote.rb",
     "book_code/with_rspec/locknote.rb",
     "book_code/with_rspec/note_spec.rb",
     "book_code/with_rspec/should_examples.rb",
     "features/step_definitions/win_gui_steps.rb",
     "features/support/env.rb",
     "features/win_gui.feature",
     "lib/note.rb",
     "lib/note/java/jemmy.jar",
     "lib/note/java/jnote.rb",
     "lib/note/java/jruby_basics.rb",
     "lib/note/java/junquenote_app.rb",
     "lib/note/java/note_spec.rb",
     "lib/note/win/locknote.rb",
     "lib/win_gui.rb",
     "lib/win_gui/constants.rb",
     "lib/win_gui/def_api.rb",
     "lib/win_gui/string_extensions.rb",
     "lib/win_gui/win_gui.rb",
     "lib/win_gui/window.rb",
     "old/windows_basics.rb",
     "old/wnote.rb",
     "old/wnote_spec.rb",
     "spec/note/win/locknote_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/test_apps/locknote/LockNote.exe",
     "spec/win_gui/def_api_spec.rb",
     "spec/win_gui/string_extensions_spec.rb",
     "spec/win_gui/win_gui_spec.rb",
     "spec/win_gui/window_spec.rb",
     "win_gui.gemspec"
  ]
  s.homepage = %q{http://github.com/arvicco/win_gui}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Rubyesque interfaces and wrappers for Win32 API GUI functions}
  s.test_files = [
    "spec/note/win/locknote_spec.rb",
     "spec/spec_helper.rb",
     "spec/win_gui/def_api_spec.rb",
     "spec/win_gui/string_extensions_spec.rb",
     "spec/win_gui/window_spec.rb",
     "spec/win_gui/win_gui_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<win32-api>, [">= 1.4.5"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
    else
      s.add_dependency(%q<win32-api>, [">= 1.4.5"])
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<cucumber>, [">= 0"])
    end
  else
    s.add_dependency(%q<win32-api>, [">= 1.4.5"])
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<cucumber>, [">= 0"])
  end
end

