require 'set'
require 'ostruct'

def initialize_path path
  unless @internal_pages[path]
    @internal_pages[path]= OpenStruct.new({fragments: Set.new, referer: Set.new})
  end
end

def collect_targets url

  @internal_pages ||= {} 
  @external_uris ||= Set.new()

  visit url

  current_uri= Addressable::URI.parse(current_url)

  $logger.info "COLLECTING targets for #{current_uri.path}"

  initialize_path current_uri.path


  local_targets = all("a").map{|a| a[:href]} \
    .map{|href| Addressable::URI.parse(href)} \
    .map{|t| current_uri + t } \
    .map(&:normalize)

  local_targets.each do |target| 
    if Capybara.app_host == target.site
      unless @internal_pages [target.path]
        initialize_path target.path
        collect_targets target
      end
      @internal_pages[target.path][:fragments].add target.fragment if target.fragment.present?
      @internal_pages[target.path][:referer].add current_uri.path
    else
      @external_uris.add(target)
    end
  end
end


