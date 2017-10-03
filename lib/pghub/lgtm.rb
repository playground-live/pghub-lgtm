require 'pghub/lgtm/version'
require 'mechanize'

module PgHub
  module Lgtm
    class << self
      def post_to(issue_path)
        md_link = md_link_from('http://lgtm.in/g')
        comment_client = GithubAPI.new(issue_path)
        comment_client.post(md_link)
      end

      private

      def md_link_from(url)
        agent = Mechanize.new
        agent.redirect_ok = true
        img_url = ''

        3.times do |i|
          page = agent.get(url)

          raise 'Markdown URL is not found in http://lgtm.in/g.' unless page.at('input#dataUrl')
          img_url = page.at('input#dataUrl')[:value].gsub(%r{\/i\/}, '/p/')

          break if valid_redirect_link?(img_url)

          raise "Many invalid URLs in #{url}" if i == 2
        end

        "![lgtm](#{img_url})"
      end

      def valid_redirect_link?(url)
        redirect_url = redirect_from(url)
        response = Net::HTTP.get_response(URI.parse(redirect_url))
      rescue
        return false
      else
        return response.code == '200' ? true : false
      end

      def redirect_from(url)
        Net::HTTP.get_response(URI.parse(url))['location']
      end
    end
  end
end
