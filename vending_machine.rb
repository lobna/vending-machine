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

  def initialize (change)
    @value = change[:value]
    @count = change[:count]
    @unit = change[:unit]
  end 

end

class Transaction
  attr_accessor :product_id, :money_paid, :returned_money
end


class VendingMachine
  attr_accessor :products, :changes, :transactions , # will be replaced with has many when connected to database
                :current_transaction  
  def start   
  
    load_machine  
    loop do 
      welcome_message
      next  unless get_order
    end
  end

  def load_machine
    @transactions = []
    @products = []
    @changes = []
    $products.each do |p|
      @products << Product.new(p)
    end 

    $changes.each do |c|
      @changes << Change.new(c)
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
   
    success = pay(selected.price)  
    if success
      get_piece(order-1) 
      @transactions << @current_transaction
    end
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
      success = get_changes(@current_transaction.returned_money)

      if success
        puts "Pick your returned money #{@current_transaction.returned_money}"
      else
       puts "No available changes please pick back your money, Sorry for that"
       return false
      end
    end
    true
  end

  def get_piece(index)
    @products[index].count -= 1
    puts "Thank you for using out vending machine, Please pick and enjoy your #{@products[index].name} then press any button"
    any = gets
  end 

  def get_changes(return_value)

    @current_transaction.returned_money = [] 
    @changes.reverse.each do |x|
      next if x.count < 1  #bypass the finished changes
       
      if return_value >= x.value
        until return_value < x.value       
          return_value -= x.value
          x.count -= 1
          @current_transaction.returned_money << x.value
          puts "return_value #{return_value} change value : #{x.value}"
        end
      end

    end

    return false  if return_value.to_i > 0 #no available changes
    return true 
  end


end

vending = VendingMachine.new
vending.start