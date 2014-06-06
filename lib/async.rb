class Async
  def run
    system('ruby daemon/FuzzySeal.rb')
  end
  handle_asynchronously :run
end