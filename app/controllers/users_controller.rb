class UsersController < ApplicationController

  def create
    auth_hash = request.env["omniauth.auth"]
    user = User.find_by(uid: auth_hash[:uid], provider: "github")
    if user
      flash[:success] = "Logged in as returning user #{user.username}"
    else
      user = User.build_from_github(auth_hash)
      if user.save
        flash[:success] = "Logged in as new user #{user.username}"
      else
        flash[:error] = "Could not create new user account: #{user.errors.messages}"
        return redirect_to root_path
      end
    end
    session[:user_id] = user.id
    return redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = "Successfully logged out!"
    redirect_to root_path
    return
  end

  def current
    @current_user_products = @current_user.products

    cartitems_orderplaced = @current_user.cartitems.where(fulfillment_status: "order placed" )
    @not_shipped = cartitems_orderplaced.count

    unless @current_user
      flash[:error] = "You must be logged in to see this page"
      redirect_to root_path
      return
    end
  end

  def fulfillment
    cartitems_orderplaced = @current_user.cartitems.where(fulfillment_status: "order placed" )
    @not_shipped = cartitems_orderplaced.count

    # merchant_orders returns a hash where the key is the cart, the value an array of cart items belonging to the user
    @pending_orders = @current_user.merchant_orders(status = "pending")
    @paid_orders = @current_user.merchant_orders(status = "paid")
    @complete_orders = @current_user.merchant_orders(status = "complete")

    @pending_revenue = @current_user.revenue("pending")
    @paid_revenue = @current_user.revenue("paid")
    @complete_revenue = @current_user.revenue("complete")

  end
end
