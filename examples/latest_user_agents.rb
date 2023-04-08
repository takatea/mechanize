require 'mechanize'

# TODO: Chrome で一旦
BASE_URL = "https://www.whatismybrowser.com/guides/the-latest-user-agent"

class LatestUserAgents

    def initialize
        @agent = Mechanize.new.tap{|a| a.user_agent_alias="Mac Firefox" }
        @user_agents = {}
    end

    def edge
    end

    def firefox
        page = @agent.get(BASE_URL + "/firefox")
        desktop_dom = page.css('h2').find { |dom| "Latest Firefox on Desktop User Agents".include? dom }
        table_dom = desktop_dom.css('+ .listing-of-useragents')

        windows = { windows: table_dom.css('td:contains("Windows")').css("+ td .code").text }
        macOS = { macOS: table_dom.css('td:contains("Macos")').css("+ td .code").text }

        linux_doms = table_dom.css('td:contains("Linux")').css("+ td .code")
        linux = { linux: linux_doms.find{ |dom | dom.text.include? "Ubuntu; Linux x86_64" }.text }

        @user_agents[:firefox] = {**windows, **linux, **macOS}
    end

    def safari
    end

    def chrome
        page = @agent.get(BASE_URL + "/chrome")

        windows_dom = page.css('h2').find { |dom| "Latest Chrome on Windows 10 User Agents".include? dom }
        windows = { windows: windows_dom.css("+ .listing-of-useragents .code").first.text }

        linux_dom = page.css('h2').find { |dom| "Latest Chrome on Linux User Agents".include? dom }
        linux = { linux: linux_dom.css("+ .listing-of-useragents .code").first.text }

        macOS_dom = page.css('h2').find { |dom| "Latest Chrome on macOS User Agents".include? dom }
        macOS = { macOS: macOS_dom.css("+ .listing-of-useragents .code").first.text }

        # NOTE: maybe typo :iOS Android
        iOS_dom = page.css('h2').find { |dom| "Latest Chrome on iOS Android User Agents".include? dom }
        iOS = { 
            iphone: iOS_dom.css("+ .listing-of-useragents .code")[0].text,
            ipad: iOS_dom.css("+ .listing-of-useragents .code")[1].text,
        }

        android_dom = page.css('h2').find { |dom| "Latest Chrome on Android User Agents".include? dom }
        android = { android: android_dom.css("+ .listing-of-useragents .code").first.text }

        @user_agents[:chrome] = {**windows, **linux, **macOS, **iOS, **android}
    end
end

agent = LatestUserAgents.new
agent.chrome.each { |key, value|  p "#{key}: #{value}" } 
sleep 1
agent.firefox.each { |key, value|  p "#{key}: #{value}" } 
