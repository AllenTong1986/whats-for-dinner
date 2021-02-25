require 'csv'

task :whats_for_dinner, [:my_fridge, :my_recipes] => :environment do |_task, args|
  begin
    recipes = Recipe.new(args[:my_recipes]).recipes
    ingredients = Fridge.new(args[:my_fridge]).ingredients

    puts "Dinner tonight: "
  rescue ArgumentError
    puts "Invalid input files."
  end
end

class Recipe
  attr_reader :recipes_json

  def initialize(recipes_json)
    @recipes_json = Rails.root.join("lib/tasks/#{recipes_json}").to_s
  end

  def recipes
    ActiveSupport::JSON.decode(File.read(recipes_json))
  end
end

class Fridge
  attr_reader :fridge_csv, :ingredients

  def initialize(fridge_csv)
    @fridge_csv = Rails.root.join("lib/tasks/#{fridge_csv}")
    @ingredients = fill_fridge
  end

  private

  # Return a hash. Example: {"bread_2021-03-05" => {quantity: 2, um: "slices"}}  
  def fill_fridge
    {}.tap do |fridge|
      ::CSV.foreach(fridge_csv, headers: true) do |row|
        if fridge["#{row[0]}-#{row[3]}"]
          fridge["#{row[0]}-#{row[3]}"][:quantity] += Integer(row[1])
        else
          fridge["#{row[0]}-#{row[3]}"] = {quantity: Integer(row[1]), um: row[2], expiry_date: row[3]}
        end
      end
    end
  end
end
