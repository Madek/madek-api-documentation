require 'spec_helper'
require 'collect_pages'
require 'matchers'

describe "The site", type: :feature  do

  before :all do
    collect_targets "/"
    $logger.debug internal_pages: @internal_pages
    $logger.debug external_uris: @external_uris
  end

  it "passes spellchecking", type: :feature do
    @internal_pages.each do |path,properties|
      expect(path).to pass_spellcheck(properties)
    end
  end

  it "has only existing href targets", type: :feature do
    @internal_pages.each do |path,properties|
      expect(path).to pass_existence_check(properties)
    end
  end

  it "hashtag targets exist", type: :feature do 
    @internal_pages.each do |path,properties|
      expect(path).to pass_hastag_check(properties)
    end
  end

  it "points only to existing external pages", type: :feature do
    @external_uris.each do |external_uri|
      expect(external_uri).to be_an_existing_uri
    end
  end

end


