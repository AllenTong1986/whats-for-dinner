require 'csv'

task :whats_for_dinner, [:my_fridge, :my_recipes] => :environment do |_task, args|
  begin
    recipe = Recipe.new(args[:my_recipes])
    ingredients = Fridge.new(args[:my_fridge]).ingredients

    if dinner = recipe.prepare(ingredients)
      puts dinner
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
    @recipes_json = Rails.root.join("lib/tasks/#{recipes_json}")
  end

  # @param [Hash] ingredients
  # e.g.: {"bread-05/03/2021" => {quantity: 2, um: "slices", expiry_date: "05/03/2021"}}
  #
  # @return [String]
  #
  def prepare(ingredients)
    possible_recipies =
      {}.tap do |acc|
        recipes.each do |recipe|
          acc.merge!(check_ingredients_and_return_possible_dinner(recipe, ingredients))
        end
      end

    possible_recipies.select {|k, v| v == possible_recipies.values.min }.keys.first
  end

  private

  # @return [Array<Hash>]
  # e.g.: [{
  #         "name"=>"Toasted Cheese",
  #         "ingredients"=> [
  #           {"item"=>"bread", "quantity"=>"2", "unit-of-measure"=>"slices"},
  #           {"item"=>"cheese", "quantity"=>"3", "unit-of-measure"=>"slices"}]
  #        }]
  #
  def recipes
    @recipes ||= ActiveSupport::JSON.decode(File.read(recipes_json))
  end

  # Check if fridge has enough ingredients for the recipe then return with recipe name and
  # its ingredient closest expiry date.
  #
  # @param [Hash] recipe
  # e.g. {"name"=>"Toasted Cheese",
  #       "ingredients"=>[{"item"=>"bread", "quantity"=>"2", "unit-of-measure"=>"slices"},
  #                       {"item"=>"cheese", "quantity"=>"3", "unit-of-measure"=>"slices"}]}
  # @param [Hash<Hash>] ingredients
  # e.g.: {"bread-05/03/2021" => {quantity: 2, um: "slices", expiry_date: "05/03/2021"}}
  #
  # @return {"Toasted Cheese" => "05/03/2021", "Vegemite Sandwich" => "25/12/2020"}
  #
  def check_ingredients_and_return_possible_dinner(recipe, ingredients)
    is_possible_dinner = true
    closest_use_by_date = Date.current.strftime("%d/%m/%Y")

    recipe["ingredients"].each do |recipe_ingredient|
      closest_use_by_date = Date.current.strftime("%d/%m/%Y")
      needed_quantity = Integer(recipe_ingredient["quantity"])

      ingredients.select { |k, v| k.split('-')[0] == recipe_ingredient["item"] }.each do |u, x|
        needed_quantity -= x[:quantity]
        closest_use_by_date = x[:expiry_date] if Date.parse(closest_use_by_date) > Date.parse(x[:expiry_date])
      end

      is_possible_dinner = false if needed_quantity > 0
    end

    { recipe["name"] => closest_use_by_date } if is_possible_dinner
  end
end

class Fridge
  attr_reader :fridge_csv, :ingredients

  def initialize(fridge_csv)
    @fridge_csv = Rails.root.join("lib/tasks/#{fridge_csv}")
    @ingredients = fill_fridge
  end

  private

  # @return [Hash]
  # e.g.: {"bread-05/03/2021" => {quantity: 2, um: "slices", expiry_date: "05/03/2021"}}
  #
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
