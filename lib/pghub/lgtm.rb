require 'pghub/base'
require 'pghub/lgtm/version'
require 'mechanize'

class MarkdownUrlNotFound < StandardError; end
class ManyInvalidUrls < StandardError; end

module Pghub
  module Lgtm
    class << self
      def post(issue_path)
        comment_client = GithubAPI.new(issue_path)
        comment_client.post(get_md_link)
      end

      private

      def get_md_link
        agent = Mechanize.new
        img_url = ''

        3.times do |i|
          page = agent.get('http://lgtm.in/g')

          raise MarkdownUrlNotFound, 'Markdown URL is not found in http://lgtm.in/g.' unless page.at('input#dataUrl')
          img_url = page.at('input#dataUrl')[:value].gsub(%r{\/i\/}, '/p/')

          break if valid_redirect_link?(img_url)

          raise ManyInvalidUrls, "Many invalid URLs in #{url}" if i == 2
        end

        "![lgtm](#{img_url})"
      end

      def valid_redirect_link?(url)
        redirect_url = get_response(url)['location']
        response = get_response(redirect_url)
        return response.code == '200' ? true : false
      rescue URI::InvalidURIError
        return false
      end

      def get_response(url)
        Net::HTTP.get_response(URI.parse(url))
      end
    end
  end
end
