require 'pghub/lgtm/version'
require 'mechanize'

module PgHub
  module Lgtm
    class << self
      def post_to(issue_path)
        md_link = md_link_from('http://lgtm.in')
        comment_client = GithubAPI.new(issue_path)
        comment_client.post(md_link)
      end

      private

      def md_link_from(url)
        agent = Mechanize.new
        obtained_url = ''

        5.times do |i|
          raise 'Random button is not found in http://lgtm.in.' unless agent.get(url).link_with(text: 'Random')
          page = agent.get(url).link_with(text: 'Random').click

          raise 'Markdown text is not found in http://lgtm.in.' unless page.at('input#dataUrl')
          obtained_url = page.at('input#dataUrl')[:value]

          break if valid_link?(obtained_url)

          raise 'Invalid URL' if i == 4
        end

        "![lgtm](#{convert_into_img_link(obtained_url)})"
      end

      def convert_into_img_link(link)
        link.gsub(%r{\/i\/}, '/p/')
      end

      def valid_link?(url)
        response = Net::HTTP.get_response(URI.parse(url))
      rescue
        return false
      else
        return response.code == '200' ? true : false
      end
    end
  end
end
