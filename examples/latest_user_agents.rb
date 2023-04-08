require 'mechanize'

# TODO: Chrome で一旦
BASE_URL = "https://www.whatismybrowser.com/guides/the-latest-user-agent"

class LatestUserAgents

    def initialize
        @agent = Mechanize.new.tap{|a| a.user_agent_alias="Mac Firefox" }
        @user_agents = {}
    end

    def edge
        page = @agent.get(BASE_URL + "/edge")

        windows_dom = page.css("h2:contains('Latest Edge on Windows User Agents')")
        @user_agents[:edge] = {
            windows: windows_dom.css("+ .listing-of-useragents .code").first.text
        }
    end

    def firefox
        page = @agent.get(BASE_URL + "/firefox")

        desktop_dom = page.css("h2:contains('Latest Firefox on Desktop User Agents')")
        table_dom = desktop_dom.css('+ .listing-of-useragents')

        windows = { windows: table_dom.css('td:contains("Windows")').css("+ td .code").text }
        macOS = { macOS: table_dom.css('td:contains("Macos")').css("+ td .code").text }
        linux = { linux: table_dom.css('td:contains("Linux")').css("+ td .code:contains('Ubuntu; Linux x86_64')").text }

        @user_agents[:firefox] = {**windows, **linux, **macOS}
    end

    def safari
        page = @agent.get(BASE_URL + "/safari")

        macOS_dom = page.css("h2:contains('Latest Safari on macOS User Agents')")
        iOS_dom = page.css("h2:contains('Latest Safari on iOS User Agents')")

        @user_agents[:safari] = {
            macOS: macOS_dom.css("+ .listing-of-useragents .code").first.text,
            iphone: iOS_dom.css("+ .listing-of-useragents").css("tr:contains('Iphone') .code").text,
            ipad: iOS_dom.css("+ .listing-of-useragents").css("tr:contains('Ipad') .code").text,
        }
    end

    def chrome
        page = @agent.get(BASE_URL + "/chrome")

        windows_dom = page.css("h2:contains('Latest Chrome on Windows 10 User Agents')")
        linux_dom = page.css("h2:contains('Latest Chrome on Linux User Agents')")
        macOS_dom = page.css("h2:contains('Latest Chrome on macOS User Agents')")
        android_dom = page.css("h2:contains('Latest Chrome on Android User Agents')")

        @user_agents[:chrome] = {
            windows: windows_dom.css("+ .listing-of-useragents .code").first.text,
            linux: linux_dom.css("+ .listing-of-useragents .code").first.text,
            macOS: macOS_dom.css("+ .listing-of-useragents .code").first.text,
            android: android_dom.css("+ .listing-of-useragents .code").first.text
        }
    end
end

agent = LatestUserAgents.new

puts "====== Chrome ======"
agent.chrome.each { |key, value|  p "#{key}: #{value}" } 
sleep 1

puts "====== Firefox ======"
agent.firefox.each { |key, value|  p "#{key}: #{value}" } 
sleep 1

puts "====== Safari ======"
agent.safari.each { |key, value|  p "#{key}: #{value}" } 
sleep 1

puts "====== Edge ======"
agent.edge.each { |key, value|  p "#{key}: #{value}" } 