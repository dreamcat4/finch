class Ruhoh
  module Converter
    module Markdown

      def self.extensions
        ['.md', '.markdown']
      end
      
      def self.convert(content)
        require 'redcarpet'
        
        rc_html_render_opts = {
          :with_toc_data => true,
          :__pad => nil
        }
        # :hard_wrap => true,
        # :prettify => true, # doesnt seem to work

        rc_markdown_opts = {
          :no_intra_emphasis => true,
          :fenced_code_blocks => true,
          :autolink => true,
          :strikethrough => true,
          :superscript => true,
          :underline => true,
          :__pad => nil
        }
        # :tables => true, # messes up indented code blocks
        # :highlight => true, # doesnt seem to work
        # :footnotes => true, # doesnt seem to work

        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(rc_html_render_opts), rc_markdown_opts)
        output = markdown.render(content)
        
        # Render a table of contents
        if content =~ /\[\[ *toc *\]\]/
          markdown_toc = Redcarpet::Markdown.new(Redcarpet::Render::HTML_TOC)
          output.gsub!(/\[\[ *toc *\]\]/, markdown_toc.render(content))
        end
        
        return output
      end
    end
  end
end
