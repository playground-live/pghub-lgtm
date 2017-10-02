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

        5.times do |i|
          raise 'Random button is not found in http://lgtm.in.' unless agent.get(url).link_with(text: 'Random')
          page = agent.get(url).link_with(text: 'Random').click

          raise 'Markdown text is not found in http://lgtm.in.' unless page.at('input#dataUrl')
          url = page.at('input#dataUrl').inner_text

          break if valid_md_link?("http://lgtm.in/i/0KN4MtJRp")

          raise 'There are not valid URL' if i == 4
        end

        "![lgtm](#{url})"
      end

      def valid_md_link?(url)
        connection = Faraday.new(url: url) do |faraday|
          faraday.request :multipart
          faraday.request :url_encoded
          faraday.response :raise_error
          faraday.adapter :net_http
        end
        connection.get
        return true
      rescue
        return false
      end
    end
  end
end
