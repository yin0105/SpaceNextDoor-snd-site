# frozen_string_literal: true

ActiveAdmin.register Channel do
  actions :index, :show

  controller do
    helper ActionView::Helpers::UrlHelper
    helper ImagesHelper

    def scoped_collection
      end_of_association_chain.includes(:space, :host, :guest)
    end
  end

  filter :guest
  filter :host
  filter :space
  filter :order

  includes :host, :guest

  index do
    column :space
    column :host
    column :guest
    column :latest_message do |resource|
      truncate resource.messages.reorder(id: :desc).first&.content, length: 100
    end
    column :created_at, sortable: :created_at
    column :updated_at, sortable: :updated_at
    actions
  end

  show title: :space_name do
    channel.messages.includes(:user, :images).each do |message|
      panel message.user.name do
        attributes_table_for message do
          row :content
          row :images do |resource|
            capture do
              resource.images.each { |image| concat image_thumb_with_link(image) }
            end
          end
          row :created_at
        end
      end
    end
  end
end
