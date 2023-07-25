module GetInput
  def print_options(options)
    options.each.with_index do |option, index|
      print "#{index + 1}. #{option.capitalize}      "
    end
    puts ""
  end

  def get_with_options(prompt, options)
    input = ""
    until options.include?(input)
      puts prompt.capitalize
      print_options(options)
      print "> "
      input = gets.chomp.downcase
    end
    puts ""
    input
  end

  def get_with_options_capitalize(prompt, options)
    input = ""
    until options.include?(input)
      puts prompt.capitalize
      print_options(options)
      print "> "
      input = gets.chomp.capitalize
    end
    puts ""
    input
  end

  def get_input(prompt)
    input = ""
    while input.empty?
      puts prompt
      print "> "
      input = gets.chomp
    end
    puts ""
    input
  end

  def get_name_pokemon(prompt)
    puts prompt
    print "> "
    input = gets.chomp
    puts ""
    input
  end
end
