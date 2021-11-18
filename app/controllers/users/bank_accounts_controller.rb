# frozen_string_literal: true

module Users
  class BankAccountsController < ApplicationController
    include HostEditInfoFlow
    skip_authorization_check

    def show
      set_identity
      load_bank_account
    end

    def new
      set_identity
      build_bank_account
    end

    def create
      build_bank_account
      save_bank_account
    end

    private

    def bank_account_params
      params.require(:bank_account).permit(:country, :bank_code, :account_name, :account_number, :bank_name, :branch_code)
    end

    def load_bank_account
      @bank_account ||= bank_account_scope
    end

    def build_bank_account
      @bank_account ||= BankAccount.new(user: current_user)
    end

    def save_bank_account
      @bank_account.assign_attributes(bank_account_params)

      if @bank_account.save
        redirect_to success_redirect_path
      else
        render :new
      end
    end

    def bank_account_scope
      current_user.bank_account
    end

    def set_identity
      @identity = params[:identity]
    end

    def success_redirect_path
      return host_next_edit_flow_path if is_host?(params[:bank_account][:identity])

      bank_account_path
    end
  end
end
