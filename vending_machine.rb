require "./data.rb"

class Product
  attr_accessor :count, :name, :price

  def initialize (product)
  	@name = product[:name]
  	@count = product[:count]
  	@price = product[:price]
  end 
end


class Change
  attr_accessor :value, :count, :unit
end

class Transaction
  attr_accessor :product_id, :money_paid, :returned_money
end


class VendingMachine
  attr_accessor :products, :changes, :transactions , # will be replaced with has many when connected to database
                :current_transaction  
  def start   
  
    load_machine  
    @transactions ||= []
    loop do 
      welcome_message
      next  unless get_order
    end
  end

  def load_machine
    @products = []
    $products.each do |p|
      @products << Product.new(p)
    end 
  end

  def welcome_message
  	puts "Welcome to your vending machine this is our available products please select one"
  	list_items
  end

  def list_items
  	i = bullet = 0
  	@products.each do |obj|	
  	  i += 1
  	  if obj.count > 0
  	    puts "#{i} - #{obj.name} ====> #{obj.price} LE  ========== Available (#{obj.count})pieces"
  	  else
  	    puts "#{i} - #{obj.name} ====> Not available"
  	  end
  	end
  end

  def get_order
    order = 0
    @current_transaction = Transaction.new
    puts "Please insert the item number " 

    until (1..@products.size+1).include?(order)
      order = gets.to_i
      puts "Wrong selection please insert a correct item"  unless (1..@products.size+1).include?(order)
    end
    @current_transaction.product_id = order

    selected = @products[order-1]
   

    if selected.count < 1
     puts "Sorry this item is not available right now, Please recheck the menu again and select another item" 
     return false
    end
   
    pay(selected.price)  
    get_piece(order-1)
    @transactions << @current_transaction
  end

  def pay(price)
    puts "Please Pay #{price} LE"
    paid = 0
    
    until paid >= price
      paid += gets.to_i
      puts "Please add equal or greater than the price "  if paid < price
    end

    puts "You have paid #{paid} LE"
    @current_transaction.money_paid = paid

    if paid > price
      @current_transaction.returned_money = paid - price
      get_changes(@current_transaction.returned_money)
      puts "Pick your returned money #{@current_transaction.returned_money}"
    end

  end

  def get_piece(index)
 	  @products[index].count -= 1
    puts "Thank you for using out vending machine, Please pick and enjoy your #{@products[index].name} then press any button"
    any = gets
  end 

  def get_changes(value)
  end

end

vending = VendingMachine.new
vending.start