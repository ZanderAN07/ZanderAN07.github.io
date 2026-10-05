# frozen_string_literal: true

require "nokogiri"

site_dir = ENV.fetch("SITE_DIR", File.expand_path("../_site", __dir__))
base_url = ENV.fetch("BASEURL", "").strip
base_url = "/#{base_url}" unless base_url.empty? || base_url.start_with?("/")
base_url = base_url.chomp("/") unless base_url == "/"

page = Nokogiri::HTML5(File.read(File.join(site_dir, "index.html"), encoding: "UTF-8"))
failures = []

profile = page.at_css("main .portfolio-profile")
failures << "expected a simple profile inside the main content" unless profile

if profile
  failures << "expected the profile to identify Zhenbin An" unless profile.at_css("h1")&.text.to_s.match?(/Zhenbin An/i)
  failures << "expected the profile to name the university and field" unless profile.text.match?(/University of Toronto.*Computer Science/im)
  failures << "expected a GitHub link" unless profile.at_css('a[href="https://github.com/ZanderAN07"]')
  failures << "expected an email link" unless profile.at_css('a[href="mailto:anzhenbin123@outlook.com"]')
end

failures << "the homepage should not contain secondary headings" if page.at_css("main h2, main h3")
failures << "the homepage should not contain decorative buttons" if page.at_css("main .portfolio-button")
failures << "the homepage should not contain focus cards" if page.at_css("main .focus-grid, main .focus-card")
failures << "the homepage should not contain a closing callout" if page.at_css("main .portfolio-closing")
failures << "projects should stay hidden until real work is added" if page.at_css("main #projects")
failures << "project headings should stay hidden until real work is added" if page.css("main h1, main h2, main h3").any? { |heading| heading.text.match?(/projects?|项目/i) }
failures << "the homepage should not show a recent-updates panel when there are no posts" if page.at_css("#access-lastmod")

retired_posts = ["VideoTest", "测试1"]
retired_posts.each do |title|
  failures << "retired post #{title} should not appear on the homepage" if page.text.include?(title)
end

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
