module Shoppe
  class SubscriptionsController < Shoppe::ApplicationController
    before_filter { @active_nav = :subscriptions }

    def index
      @query = Subscription.order("updated_at DESC").includes(:subscription_items, :user).page(params[:page]).search(params[:q])
      @subscriptions = @query.result
      @unpaged_subscriptions = @subscriptions.except(:limit, :offset)
      respond_to do |format|
        format.html {render 'index'}
        format.csv { send_data @unpaged_subscriptions.to_csv, filename: "Suscripciones-TuNaranja-#{Date.today}.csv" }
      end
    end

    def show
      @subscription = Subscription.find(params[:id])
      @user = @subscription.user
    end

    def update
      @subscription = Subscription.find(params[:id])
      if @subscription.update(subscription_params)
        flash[:notice]= "La suscripción ##{@subscription.id} suscripción fue actualizada exitosamente"
      else
       flash[:notice]= "La suscripción ##{@subscription.id} suscripción no se pudo actualizar "
      end
      redirect_to subscriptions_path
    end

    def search
      index
    end

    def subscription_params
      params.require(:subscription).permit(:periodicity, :credit_card_id, :status, subscription_items_attributes:[:id, :quantity, :shoppe_product_id, :_destroy])
    end
  end
end
