class CartsController < ApplicationController

  def show
    @cart = @current_cart
    @cartitems = @cart.cartitems.order(created_at: :desc)
  end

  def purchase_form
    @cart = @current_cart
  end

  def purchase

    @cart = @current_cart
    @cart.assign_attributes(status: "paid", purchase_datetime: Time.now)

    if @cart.update(cart_params)
      flash[:success] = "Your order has been placed!"
      @cart.update_item_fulfillment
      @cart.update_inventory
      @cart.save
      session[:cart_id] = nil
      current_cart
      redirect_to view_confirmation_path(@cart.id)
      return
    else
      flash.now[:error] = "There was an error in placing your order"
      flash.now[:error_message] = @cart.errors.messages
      render :purchase_form, status: :bad_request
      return
    end
  end

  def view_confirmation
    @ordered_cart = Cart.find(params[:id])
  end

  def order_details
    @ordered_cart = Cart.find(params[:id])
  end

  private

  def cart_params
    return params.require(:cart).permit(:email, :mailing_address, :name, :cc_number,
                                        :cc_expiration, :cc_cvv, :zip)
  end

end
