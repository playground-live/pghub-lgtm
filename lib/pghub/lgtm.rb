require "pghub/lgtm/version"
require "mechanize"

module PgHub
  module Lgtm
    LGTM_MARKDOWN_PATTERN = /(!\[LGTM\]\(.+\))\]/

    class << self
      def post_md_image(issue_path)
        text = markdown_lgtm_from('http://lgtm.in')

        if text =~ LGTM_MARKDOWN_PATTERN
          image_md_link = Regexp.last_match[1]
          # image_md_linkが正常なURLか判定する
          comment_client = GithubAPI.new(issue_path)
          comment_client.post(image_md_link)
        else
          raise 'Invalid text near "LGTM"'
        end
      end

      private

      def markdown_lgtm_from(url)
        agent = Mechanize.new

        raise 'Random button is not found in http://lgtm.in.' unless agent.get(url).link_with(text: 'Random')
        page = agent.get(url).link_with(text: 'Random').click

        raise 'Markdown text is not found in http://lgtm.in.' unless page.at('textarea#markdown')
        page.at('textarea#markdown').inner_text
      end
    end
  end
end
