require 'open3'
require 'addressable/uri'
require 'faraday'
require 'rspec/expectations'

RSpec::Matchers.define :pass_hastag_check do |properties|
  match do |path|
    $logger.debug path
    visit path
    if current_path =~ /\/$/ or current_path =~ /html$/
      properties.fragments.each do |fragment|
        $logger.debug "FRAGMENT #{fragment}"
        find("##{fragment}")
      end
    else
      true
    end
  end
  failure_message_for_should do |path|
    "Expected that #{path} would pass the spellcheck. However, it contains:\n  #{@res} \n in its text: \n#{@text}"
  end
end



RSpec::Matchers.define :pass_spellcheck do |properties|
  match do |path|
    visit path
    $logger.info "SPELLCHECKING visit #{path}"
    if current_path =~ /\/$/ or current_path =~ /html$/
      $logger.info "SPELLCHECKING: #{path}"
      stdin, stdout, stderr, wait_thr= Open3.popen3("hunspell -d en_US -p spec/hunspell_en_US -l")
      @text = page.text
      stdin.print @text
      stdin.close
      @res = stdout.read
      @res.blank? 
    else
      true
    end
  end
  failure_message_for_should do |path|
    "Expected that #{path} would pass the spellcheck. However, it contains:\n  #{@res} \n in its text: \n#{@text}"
  end
end



RSpec::Matchers.define :pass_existence_check do |properties|
  match do |path|
    $logger.info "PASS_EXISTENCE_CHECK #{path}" 
    @uri = Addressable::URI.parse(Capybara.app_host) + Addressable::URI.parse(path)
    @resp= Faraday.new().get(@uri)
    (200..299).include? @resp.status
  end
  failure_message_for_should do |path|
    "Expected that getting #{path} would be OK, but it returns #{@resp.status}"
  end
end


RSpec::Matchers.define :be_an_existing_uri do 
  match do |uri|
    unless uri.site =~ /localhost/
      $logger.info "GET check #{uri}" 
      @resp= Faraday.new(ssl: {verify: false}).get(uri)
      (200..299).include? @resp.status
    else
      true
    end
  end
  failure_message_for_should do |uri|
    "Expected that getting #{uri} would be OK, but it returns #{@resp.status}"
  end
end


