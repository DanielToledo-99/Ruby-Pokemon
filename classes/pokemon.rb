# require neccesary files
require_relative "../pokedex/pokemons"

class Pokemon
  # include neccesary modules
  attr_reader :name, :species, :level, :moves, :stats, :experience_points, :base_exp, :effort_points, :hp, :type
  attr_accessor :move

  # (complete parameters)
  def initialize(name, species, level)
    name = species if name == ""
    @name = name
    @species = species
    @level = level
    # Datos tomados de pokedex
    @type = Pokedex::POKEMONS[@species][:type]
    @base_exp = Pokedex::POKEMONS[@species][:base_exp]
    @effort_points = Pokedex::POKEMONS[@species][:effort_points]
    @growth_rate = Pokedex::POKEMONS[@species][:growth_rate]
    @base_stats = Pokedex::POKEMONS[@species][:base_stats]
    @moves = Pokedex::POKEMONS[@species][:moves]
    # Datos calculados
    @ivs = { hp: rand(0..31), attack: rand(0..31), defense: rand(0..31), special_attack: rand(0..31),
             special_defense: rand(0..31), speed: rand(0..31) }
    @evs = { hp: 0, attack: 0, defense: 0, special_attack: 0, special_defense: 0, speed: 0 }
    @experience_points = if level == 1
                           0
                         else
                           Pokedex::LEVEL_TABLES[@growth_rate][@level - 1]
                         end
    @stats = calculate_stats(@base_stats, @ivs, @evs, @level)
    @hp = nil
    @move = nil
  end

  def prepare_for_battle
    @hp = @stats[:hp]
    @move = nil
  end

  def receive_damage(damage)
    @hp -= damage
  end

  def fainted?
    !@hp.positive?
  end

  def attack(opponent)
    puts "#{name} used #{@move[:name].upcase}!"
    hit = @move[:accuracy] >= rand(1..100)

    if hit

      # Multiplier y critico
      critical = 1
      multiplier = 1
      damage = 0

      if Pokedex::SPECIAL_MOVE_TYPE.include?(move[:type])
        damage = ((((2 * @level / 5.0) + 2).floor * @stats[:special_attack] * @move[:power] / opponent.stats[:special_defense]).floor / 50.0).floor + 2
      else
        damage = ((((2 * @level / 5.0) + 2).floor * @stats[:attack] * @move[:power] / opponent.stats[:defense]).floor / 50.0).floor + 2
      end

      if rand(1..16) <= 1
        critical = 1.5
        puts "It was CRITICAL hit!"
      end

      tmp_hash = {}
      Pokedex::TYPE_MULTIPLIER.each do |type|
        next unless type[:user] == @move[:type]

        opponent.type.each do |element|
          if type[:target] == element
            tmp_hash = type
            multiplier = tmp_hash[:multiplier]
          end
        end
      end

      if multiplier <= 0.5
        puts "It's not very effective..."
      elsif multiplier >= 1.5
        puts "It's super effective!"
      elsif multiplier.zero?
        puts "It doesn't affect #{opponent.name}!"
      end

      damage = (damage * critical * multiplier).floor
      opponent.receive_damage(damage)
      puts "And it hit #{opponent.name} with #{damage} damage"
      puts ("-" * 50).to_s # puedo ponerlo en 70 de battle
    else
      puts "But it MISSED!"
    end
  end

  def increase_stats(defeat_pokemon)
    # Increase stats base on the defeated pokemon and print message "#[pokemon name] gained [amount] experience points"

    # If the new experience point are enough to level up, do it and print
    # message "#[pokemon name] reached level [level]!" # -- Re-calculate the stat
    amount = (defeat_pokemon.base_exp * defeat_pokemon.level / 7.0).floor
    @experience_points += amount
    puts "#{@name} gained #{amount} experience points"
    if @experience_points > Pokedex::LEVEL_TABLES[@growth_rate][@level]
      @level += 1
      puts "#{@name} reached level #{@level}!"
    end
    hash = { defeat_pokemon.effort_points[:type] => defeat_pokemon.effort_points[:amount] } # { speed: 1 }
    @evs.merge!(hash) { |_key, old_value, new_value| old_value + new_value }
    @stats = calculate_stats(@base_stats, @ivs, @evs, @level)
  end

  # private methods:
  # Create here auxiliary methods
  def calculate_stats(base_stats, ivs, evs, level)
    hp = (((((2 * base_stats[:hp]) + ivs[:hp] + evs[:hp]) * level) / 100) + level + 10).floor
    attack = (((((2 * base_stats[:attack]) + ivs[:attack] + evs[:attack]) * level) / 100) + 5).floor
    defense = (((((2 * base_stats[:defense]) + ivs[:defense] + evs[:defense]) * level) / 100) + 5).floor
    special_attack = (((((2 * base_stats[:special_attack]) + ivs[:special_attack] + evs[:special_attack]) * level) / 100) + 5).floor
    special_defense = (((((2 * base_stats[:special_defense]) + ivs[:special_defense] + evs[:special_defense]) * level) / 100) + 5).floor
    speed = (((((2 * base_stats[:speed]) + ivs[:speed] + evs[:speed]) * level) / 100) + 5).floor
    { hp: hp, attack: attack, defense: defense, special_attack: special_attack, special_defense: special_defense,
      speed: speed }
  end
end
