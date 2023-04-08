# frozen_string_literal: true

require 'mechanize'

BASE_URL = 'https://www.whatismybrowser.com/guides/the-latest-user-agent'

class LatestUserAgents # rubocop:todo Style/Documentation
  def initialize
    @agent = Mechanize.new.tap { |a| a.user_agent_alias = 'Mac Firefox' }
    @user_agents = {}
  end

  def edge
    page = @agent.get("#{BASE_URL}/edge")

    windows_dom = page.css("h2:contains('Latest Edge on Windows User Agents')")
    @user_agents[:edge] = {
      windows: windows_dom.css('+ .listing-of-useragents .code').first.text
    }
  end

  def firefox
    page = @agent.get("#{BASE_URL}/firefox")

    desktop_dom = page.css("h2:contains('Latest Firefox on Desktop User Agents')")
    table_dom = desktop_dom.css('+ .listing-of-useragents')

    windows = { windows: table_dom.css('td:contains("Windows")').css('+ td .code').text }
    macOS = { macOS: table_dom.css('td:contains("Macos")').css('+ td .code').text } # rubocop:todo Naming/VariableName
    linux = { linux: table_dom.css('td:contains("Linux")').css("+ td .code:contains('Ubuntu; Linux x86_64')").text }

    @user_agents[:firefox] = { **windows, **linux, **macOS } # rubocop:todo Naming/VariableName
  end

  def safari
    page = @agent.get("#{BASE_URL}/safari")

    macOS_dom = page.css("h2:contains('Latest Safari on macOS User Agents')") # rubocop:todo Naming/VariableName
    iOS_dom = page.css("h2:contains('Latest Safari on iOS User Agents')") # rubocop:todo Naming/VariableName

    @user_agents[:safari] = {
      macOS: macOS_dom.css('+ .listing-of-useragents .code').first.text, # rubocop:todo Naming/VariableName
      # rubocop:todo Naming/VariableName
      iphone: iOS_dom.css('+ .listing-of-useragents').css("tr:contains('Iphone') .code").text,
      # rubocop:enable Naming/VariableName
      # rubocop:todo Naming/VariableName
      ipad: iOS_dom.css('+ .listing-of-useragents').css("tr:contains('Ipad') .code").text
      # rubocop:enable Naming/VariableName
    }
  end

  def chrome # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
    page = @agent.get("#{BASE_URL}/chrome")

    windows_dom = page.css("h2:contains('Latest Chrome on Windows 10 User Agents')")
    linux_dom = page.css("h2:contains('Latest Chrome on Linux User Agents')")
    macOS_dom = page.css("h2:contains('Latest Chrome on macOS User Agents')") # rubocop:todo Naming/VariableName
    android_dom = page.css("h2:contains('Latest Chrome on Android User Agents')")

    @user_agents[:chrome] = {
      windows: windows_dom.css('+ .listing-of-useragents .code').first.text,
      linux: linux_dom.css('+ .listing-of-useragents .code').first.text,
      macOS: macOS_dom.css('+ .listing-of-useragents .code').first.text, # rubocop:todo Naming/VariableName
      android: android_dom.css('+ .listing-of-useragents .code').first.text
    }
  end
end

agent = LatestUserAgents.new

puts '====== Chrome ======'
agent.chrome.each { |key, value| p "#{key}: #{value}" }
sleep 1

puts '====== Firefox ======'
agent.firefox.each { |key, value| p "#{key}: #{value}" }
sleep 1

puts '====== Safari ======'
agent.safari.each { |key, value| p "#{key}: #{value}" }
sleep 1

puts '====== Edge ======'
agent.edge.each { |key, value| p "#{key}: #{value}" }
