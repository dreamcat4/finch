require 'nokogiri'

class Ruhoh
  module Compiler
    class SitemapTask
      def initialize(ruhoh)
        @ruhoh = ruhoh
        load_site_sitemap
      end

      def run
        sitemap = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.urlset(:xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9") {
            @ruhoh.collections.acting_as_pages.each do |name|
              collection = @ruhoh.collection(name)
              next unless collection.compiler?
              add_to_sitemap(xml, collection)
            end
          }
        end

        # FileUtils.cd(@ruhoh.paths.compiled) {
        FileUtils.cd(@ruhoh.compiled_path("")) {
          sitemap_file_name = @config['file_name'] || "sitemap.xml"
          File.open(sitemap_file_name, 'w'){ |p| p.puts sitemap.to_xml }

          Ruhoh::Friend.say { green "  > #{sitemap_file_name}" }
        }
      end

      protected

      def add_to_sitemap(xml, collection)
        production_url = @ruhoh.config['production_url']
        update_page_sitemap collection

        collection.all.each do |page|
          xml.url {
            xml.loc_ "#{production_url}#{page['url']}"
            xml.lastmod_ File.mtime(page.pointer['realpath']).strftime("%Y-%m-%d")
            xml.priority_ page.data['priority']
            xml.changefreq_ page.data['changefreq']
          }
        end
      end

      def collection_sitemap(collection)
        @config.merge(collection.config['sitemap'] || {})
      end

      def get_page_default_sitemap(collection)
        sitemap = collection_sitemap collection
        Hash[ ['changefreq', 'priority'].map {|d| [d, sitemap[d]]} ]
      end

      def update_page_sitemap(collection)
        default_config = get_page_default_sitemap collection
        collection.all.each do |page|
          page.data.merge!(default_config) { |key, vold| vold }
        end
      end

      def load_site_sitemap
        default_config = {'changefreq' => 'daily', 'priority' => 0.5}
        @config = @ruhoh.config['plugins']['sitemap'] || {} rescue {}
        @config.merge!(default_config){ |key, vold| vold }
      end

    end
  end
end
