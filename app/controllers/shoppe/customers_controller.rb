module Shoppe
  class CustomersController < Shoppe::ApplicationController
    before_filter { @active_nav = :customers }
    before_filter { params[:id] && @customer = Shoppe::Customer.find(params[:id]) }

    def index
      @query = Shoppe::Customer.ordered.page(params[:page]).search(params[:q])
      if params['from_date'].present?
        from_date = Date.parse(params['from_date'])
        to_date = Date.parse(params['to_date'])
        @customers = Shoppe::Customer.created_between(from_date.beginning_of_day, to_date.end_of_day)
      else
        @customers = @query.result
      end
      respond_to do |format|
        format.html {render 'index'}
        format.csv { send_data @customers.to_csv, filename: "Clientes-TuNaranja-#{Date.today}.csv" }
      end
    end

    def new
      @customer = Shoppe::Customer.new
    end

    def show
      @addresses = @customer.addresses.ordered.load
      @orders = @customer.orders.ordered.load
    end

    def create
      @customer = Shoppe::Customer.new(safe_params)
      if @customer.save
        redirect_to @customer, flash: { notice: t('shoppe.customers.created_successfully') }
      else
        render action: 'new'
      end
    end

    def update
      if @customer.update(safe_params)
        redirect_to @customer, flash: { notice: t('shoppe.customers.updated_successfully') }
      else
        render action: 'edit'
      end
    end

    def destroy
      @customer.destroy
      redirect_to customers_path, flash: { notice: t('shoppe.customers.deleted_successfully') }
    end

    def search
      index
    end

    def print_index_list
      from_date = Date.parse(params['from_date'])
      to_date = Date.parse(params['to_date'])
      @customers = Shoppe::Customer.created_between(from_date.beginning_of_day, to_date.end_of_day)
      render layout: 'shoppe/printable'
    end

    def print_info
      render layout: 'shoppe/printable'
    end

    private

    def safe_params
      params[:customer].permit(:first_name, :last_name, :company, :email, :phone, :mobile)
    end
  end
end
