# frozen_string_literal: true

module CommonContact
  extend ActiveSupport::Concern

  def new
    set_identity
    build_contact
  end

  def create
    build_contact
    save_contact
  end

  def show; end

  private

  def contact_params
    params.require(:contact).permit(:name, :phone, :email)
  end

  def build_contact
    @contact = current_role.contact || current_role.build_contact
  end

  def set_identity
    @identity = params[:identity]
  end
end
