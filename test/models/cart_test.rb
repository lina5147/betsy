require "test_helper"

describe Cart do

  before do
    @cart = carts(:cart0)
    @cartitem0 = cartitems(:cartitem0)
    @cartitem1 = cartitems(:cartitem1)
    @paid_cart = carts(:cart1)
  end

  describe "instantiation" do
    it "can be instantiated" do
      expect(@cart.valid?).must_equal true
    end

    it "has the required fields" do
      [:status, :email, :mailing_address, :name, :cc_number, :cc_expiration, :cc_cvv, :zip, :purchase_datetime].each do |field|
        expect(@cart).must_respond_to field
      end
    end
  end

  describe "validations" do
    it "requires billing information and mailing information about customer when status is not pending" do
      ["paid", "complete", "cancelled"].each do |status|
        @cart.status = status
        expect(@cart.valid?).must_equal false
      end
    end

    it "requires a 16 character credit card number when status is not pending" do
      @cart.cc_number = "12"
      ["paid", "complete", "cancelled"].each do |status|
        @cart.status = status
        expect(@cart.valid?).must_equal false
      end
    end
  end

  describe "relations" do

    it "has many cartitems" do
      expect(@cart.cartitems.length).must_equal 2
    end

    it "has_many products through cartitems" do
      expect(@cart.products.length).must_equal 2
    end
  end

  describe "update inventory" do

    it "updates the inventory after an order purchase" do

      product1 = @cartitem0.product
      product2 = @cartitem1.product
      expect(product1.inventory).must_equal 10
      expect(product2.inventory).must_equal 5


      @cart.update_inventory


      updated_product1 = @cart.cartitems.first.product
      updated_product2 = @cart.cartitems.last.product

      expect(updated_product1.id).must_equal product1.id
      expect(updated_product1.inventory).must_equal 6
      expect(updated_product2.id).must_equal product2.id
      expect(updated_product2.inventory).must_equal 1


    end

  end

  describe "total price" do
    it "can calculate the total price of the cartitems" do
      cart1 = carts(:cart0)
      cart2 = carts(:cart1)
      cart3 = carts(:cart2)
      expect(cart1.total_price).must_equal 804.00
      expect(cart2.total_price).must_equal 4400.00
      expect(cart3.total_price).must_equal 1500.00
    end

    it "should return 0 if there are no cart items" do

      cart1 = carts(:cart0)

      cart1.cartitems.destroy_all
      expect(cart1.cartitems).must_be_empty
      expect(cart1.total_price).must_equal 0

    end
  end

  describe "update item fulfillment status" do
    it "can update each cartitem's fulfillment status" do
      @paid_cart.cartitems.each do |cartitem|
        expect(cartitem.fulfillment_status).must_be_nil
      end

      @paid_cart.update_item_fulfillment
      @paid_cart.cartitems.each do |cartitem|
        expect(cartitem.fulfillment_status).must_equal "order placed"
      end
    end
  end

  describe "complete cart" do
    it "can update each cartitem's fulfillment status for a completed order" do
      @paid_cart.cartitems.each do |cartitem|
        cartitem.fulfillment_status = "order shipped"
      end

      @paid_cart.complete_cart
      expect(@paid_cart.status).must_equal "complete"
    end

  end
end
