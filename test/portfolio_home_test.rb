# frozen_string_literal: true

require "nokogiri"

site_dir = ENV.fetch("SITE_DIR", File.expand_path("../_site", __dir__))
base_url = ENV.fetch("BASEURL", "").strip
base_url = "/#{base_url}" unless base_url.empty? || base_url.start_with?("/")
base_url = base_url.chomp("/") unless base_url == "/"

page = Nokogiri::HTML5(File.read(File.join(site_dir, "index.html"), encoding: "UTF-8"))
failures = []

hero = page.at_css("main .portfolio-hero")
failures << "expected a portfolio hero inside the main content" unless hero

if hero
  failures << "expected the hero to identify Zhenbin An" unless hero.at_css("h1")&.text.to_s.match?(/Zhenbin An/i)
  failures << "expected a GitHub action" unless hero.at_css('a[href="https://github.com/ZanderAN07"]')
  failures << "expected an email action" unless hero.at_css('a[href="mailto:anzhenbin123@outlook.com"]')
end

failures << "expected an About section" unless page.at_css("main #about.portfolio-section")
failures << "expected a technical focus section" unless page.at_css("main #focus.portfolio-section")
failures << "projects should stay hidden until real work is added" if page.at_css("main #projects")
failures << "project headings should stay hidden until real work is added" if page.css("main h1, main h2, main h3").any? { |heading| heading.text.match?(/projects?|项目/i) }

sidebar_links = page.css("#sidebar .nav-link").map { |link| link["href"] }
home_path = base_url.empty? || base_url == "/" ? "/" : "#{base_url}/"
about_path = base_url.empty? || base_url == "/" ? "/about/" : "#{base_url}/about/"
failures << "expected a Home navigation link" unless sidebar_links.include?(home_path)
failures << "expected an About navigation link" unless sidebar_links.include?(about_path)
failures << "categories should be hidden from the portfolio navigation" if sidebar_links.include?("#{base_url}/categories/")
failures << "tags should be hidden from the portfolio navigation" if sidebar_links.include?("#{base_url}/tags/")
failures << "archives should be hidden from the portfolio navigation" if sidebar_links.include?("#{base_url}/archives/")

if failures.empty?
  puts "Portfolio homepage checks passed"
else
  warn failures.map { |failure| "FAIL: #{failure}" }.join("\n")
  exit 1
end
