# frozen_string_literal: true

RSpec.describe Blacklight::FacetsHelperBehavior do
  let(:blacklight_config) { Blacklight::Configuration.new }

  around { |test| Deprecation.silence(described_class) { test.call } }

  before do
    allow(helper).to receive(:blacklight_config).and_return blacklight_config
  end

  describe "render_facet_limit" do
    let(:blacklight_config) do
      Blacklight::Configuration.new do |config|
        config.add_facet_field 'basic_field'
        config.add_facet_field 'component_field', component: true
        config.add_facet_field 'non_rendering_component_field', component: true, if: false
      end
    end

    it "renders a component" do
      mock_facet = double(name: 'basic_field')
      expect(helper).to receive(:render).with(an_instance_of(Blacklight::FacetFieldListComponent))
      helper.render_facet_limit(mock_facet)
    end

    it "renders a component" do
      expect(Deprecation).to receive(:warn)
      mock_facet = double(name: 'component_field')
      expect(helper).to receive(:render).with(an_instance_of(Blacklight::FacetFieldListComponent))
      helper.render_facet_limit(mock_facet)
    end

    it "renders nothing when the condition is false" do
      mock_facet = double(name: 'non_rendering_component_field')
      expect(helper.render_facet_limit(mock_facet)).to be_blank
    end
  end

  describe "#facet_display_value" do
    it "justs be the facet value for an ordinary facet" do
      allow(helper).to receive(:facet_configuration_for_field).with('simple_field').and_return(double(query: nil, date: nil, helper_method: nil, url_method: nil))
      expect(helper.facet_display_value('simple_field', 'asdf')).to eq 'asdf'
    end

    it "allows you to pass in a :helper_method argument to the configuration" do
      allow(helper).to receive(:facet_configuration_for_field).with('helper_field').and_return(double(query: nil, date: nil, url_method: nil, helper_method: :my_facet_value_renderer))
      allow(helper).to receive(:my_facet_value_renderer).with('qwerty').and_return('abc')
      expect(helper.facet_display_value('helper_field', 'qwerty')).to eq 'abc'
    end

    it "extracts the configuration label for a query facet" do
      allow(helper).to receive(:facet_configuration_for_field).with('query_facet').and_return(double(query: { 'query_key' => { label: 'XYZ' } }, date: nil, helper_method: nil, url_method: nil))
      expect(helper.facet_display_value('query_facet', 'query_key')).to eq 'XYZ'
    end

    it "localizes the label for date-type facets" do
      allow(helper).to receive(:facet_configuration_for_field).with('date_facet').and_return(double('date' => true, :query => nil, :helper_method => nil, :url_method => nil))
      expect(helper.facet_display_value('date_facet', '2012-01-01')).to eq 'Sun, 01 Jan 2012 00:00:00 +0000'
    end

    it "localizes the label for date-type facets with the supplied localization options" do
      allow(helper).to receive(:facet_configuration_for_field).with('date_facet').and_return(double('date' => { format: :short }, :query => nil, :helper_method => nil, :url_method => nil))
      expect(helper.facet_display_value('date_facet', '2012-01-01')).to eq '01 Jan 00:00'
    end
  end

  describe '#facet_field_presenter' do
    let(:facet_config) { Blacklight::Configuration::FacetField.new(key: 'x').normalize! }
    let(:display_facet) { double }

    it 'wraps the facet data in a presenter' do
      presenter = helper.facet_field_presenter(facet_config, display_facet)
      expect(presenter).to be_a_kind_of Blacklight::FacetFieldPresenter
      expect(presenter.facet_field).to eq facet_config
      expect(presenter.display_facet).to eq display_facet
      expect(presenter.view_context).to eq helper
    end

    it 'uses the facet config to determine the presenter class' do
      stub_const('SomePresenter', Class.new(Blacklight::FacetFieldPresenter))
      facet_config.presenter = SomePresenter
      presenter = helper.facet_field_presenter(facet_config, display_facet)
      expect(presenter).to be_a_kind_of SomePresenter
    end
  end
end
