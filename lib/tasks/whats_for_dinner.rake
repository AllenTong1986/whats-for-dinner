require 'csv'

task :whats_for_dinner, [:my_fridge, :my_recipes] => :environment do |_task, args|
  begin
    recipe = Recipe.new(args[:my_recipes])
    ingredients = Fridge.new(args[:my_fridge]).ingredients

    if recipe.recipes.present?
      recipe.prepare(ingredients)
    else
      puts "Call for takeout”"
    end
  rescue ArgumentError, JSON::ParserError
    puts "Invalid input files."
  end
end

class Recipe
  attr_reader :recipes_json

  def initialize(recipes_json)
    @recipes_json = Rails.root.join("lib/tasks/#{recipes_json}").to_s
  end

  def recipes
    @recipes ||= ActiveSupport::JSON.decode(File.read(recipes_json))
  end

  def prepare(ingredients)
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
        if Date.parse(row[3]) > Date.current
          if fridge["#{row[0]}-#{row[3]}"]
            fridge["#{row[0]}-#{row[3]}"][:quantity] += Integer(row[1])
          else
            fridge["#{row[0]}-#{row[3]}"] = {quantity: Integer(row[1]), um: row[2], expiry_date: row[3]}
          end
        end
      end
    end
  end
end
