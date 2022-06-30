# frozen_string_literal: true

RSpec.describe "Search History Routes" do
  routes { Blacklight::Engine.routes }
  # paths generated by custom routes
  it "has a path for showing the search history" do
    expect(get: "/search_history").to route_to(controller: 'search_history', action: 'index')
  end
end