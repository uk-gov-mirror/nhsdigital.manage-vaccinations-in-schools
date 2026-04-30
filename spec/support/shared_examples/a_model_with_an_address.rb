# frozen_string_literal: true

shared_examples_for "a model with an address" do
  it { should normalize(:address_line_1).from(nil).to(nil) }
  it { should normalize(:address_line_1).from("").to(nil) }
  it { should normalize(:address_line_2).from(nil).to(nil) }
  it { should normalize(:address_line_2).from("").to(nil) }
  it { should normalize(:address_town).from(nil).to(nil) }
  it { should normalize(:address_town).from("").to(nil) }
  it { should normalize(:address_postcode).from(nil).to(nil) }
  it { should normalize(:address_postcode).from("").to(nil) }
  it { should normalize(:address_postcode).from(" SW111AA ").to("SW11 1AA") }
end
