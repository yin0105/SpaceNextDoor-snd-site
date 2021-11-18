# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'Imageable' do
  it { is_expected.to have_many(:images) }
  it { is_expected.to accept_nested_attributes_for(:images) }

  describe '#assign_attributes' do
    subject { create(described_class.name.underscore) }

    let(:image) { create(:image) }
    let(:derelicted_image) { create(:image) }
    let(:owned_image) { create(:image, imageable_id: 100) }

    it 'creates association with derelicted image' do
      expect do
        subject.assign_attributes(
          images_attributes: {
            0 => { id: image.id },
            1 => { id: derelicted_image.id }
          }
        )
      end.to change { derelicted_image.reload.imageable }.from(nil).to(subject)
    end

    it 'ignores owned image and leaves it unchanged' do
      expect do
        subject.assign_attributes(
          images_attributes: {
            0 => { id: image.id },
            1 => { id: derelicted_image.id },
            2 => { id: owned_image.id }
          }
        )
      end.to raise_error(StandardError)

      expect(owned_image.reload.imageable).not_to eq(subject)
    end

    context 'subject is not presisted' do
      subject { build(described_class.name.underscore) }

      it 'builds association with derelicted image' do
        expect(subject.images).not_to include(derelicted_image)
        subject.assign_attributes(images_attributes: { 0 => { id: derelicted_image.id } })
        expect(subject.images).to include(derelicted_image)
      end

      it 'ignores owned image and leaves it unchanged' do
        expect do
          subject.assign_attributes(images_attributes: { 0 => { id: owned_image.id } })
        end.to raise_error(StandardError)

        expect(subject.images).not_to include(owned_image)
      end
    end
  end
end
