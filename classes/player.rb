# require neccesary files
require_relative "../modules/get_input"
require_relative "../pokedex/moves"
require_relative "../pokedex/pokemons"
require_relative "pokemon"
require_relative "battle"

class Player
  include GetInput
  attr_reader :pokemon, :name

  def initialize(name, pokemon_name, species_pokemon, level)
    @name = name
    @pokemon = Pokemon.new(pokemon_name, species_pokemon, level)
  end

  def select_move
    move = get_with_options("#{@name}, select your move:", @pokemon.moves)
    @pokemon.move = Pokedex::MOVES[move]
  end
end

# Create a class Bot that inherits from Player and override the select_move method
class Bot < Player
  def initialize(name = nil, pokemon_name = nil, species_pokemon = nil, level = nil)
    if name.nil? && pokemon_name.nil? && species_pokemon.nil? && level.nil?
      options = Pokedex::POKEMONS.keys
      random_pokemon = options.sample
      super("Random Person", "", random_pokemon, rand(1..5)) # Configurar nivel bot
    else
      super(name, pokemon_name, species_pokemon, level)
    end
  end

  def select_move
    move = @pokemon.moves.sample
    @pokemon.move = Pokedex::MOVES[move]
  end
end
