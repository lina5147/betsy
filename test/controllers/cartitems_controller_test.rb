require "test_helper"

describe CartitemsController do
  # it "does a thing" do
  #   value(1+1).must_equal 2
  # end

  describe "create" do
    it "can create a cart item" do
      # start a new cart
      get root_path
      cart = Cart.find_by(id: session[:cart_id])

      expect{
        post product_cartitems_path(products(:product0).id)
      }.must_differ "cart.cartitems.count", 1

      must_respond_with :redirect
    end

    it "cart item quantity will not increase if there is not enough inventory" do
      # start a new cart
      get root_path
      cart = Cart.find_by(id: session[:cart_id])

      # add the product to the cart, product only has one in inventory
      post product_cartitems_path(products(:product1).id)

      cart_item = cart.cartitems.find_by(product: products(:product1))

      # add the same product again
      expect{
        post product_cartitems_path(products(:product1).id)
      }.wont_change "cart_item.qty"

      expect(flash[:error]).wont_be_nil
      must_respond_with :redirect

    end

  end

  describe "reduce_qty" do
    it "can reduce the quantity of the cart item by 1" do

      # start a new cart
      get root_path
      cart = Cart.find_by(id: session[:cart_id])

      cart_item = Cartitem.create(
          cart: cart,
          product: products(:product0),
          qty: 3,
          cost: products(:product0).cost
      )

      p cart_item.qty
      post reduce_path(cart_item.id)
      p cart_item.qty

    end
  end


  describe "destroy" do
    it "can destroy a cart item" do
      perform_login
      cart = Cart.find_by(id: session[:cart_id])
      # add a new cart item to cart
      post product_cartitems_path(products(:product0).id)

      # find the cart item from the cart
      cart_item = cart.cartitems.find_by(product: products(:product0))

      expect{
        delete cartitem_path(cart_item.id)
      }.must_change "cart.cartitems.count", -1

      must_respond_with :redirect
      must_redirect_to cart_path
    end


  end
end
