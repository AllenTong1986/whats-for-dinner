require 'spec_helper'
require 'rake'

describe "whats_for_dinner.rake" do
  before :each do
    Rake.application = Rake::Application.new
    Rake.application.rake_require "lib/tasks/whats_for_dinner", [Rails.root.to_s], []
    Rake::Task.define_task(:environment)
    allow(Rails).to receive(:root).and_return(Rails.root.join("spec"))
  end

  context "with all fresh ingredients and recipes" do
    it "should return recipe name" do
      expect do
        Rake.application.invoke_task('whats_for_dinner[all_fresh_ingredients.csv, one_recipe.json]')
      end.to output("Toasted Cheese\n").to_stdout
    end
  end

  context "with ingredient past its use-by date and rest are not enough for recipe" do
    it "should call for takeout" do
      expect do
        Rake.application.invoke_task('whats_for_dinner[ingredients_with_past_expiry_date_and_not_enough_for_recipe.csv, one_recipe.json]')
      end.to output("Call for takeout\n").to_stdout
    end
  end

  context "with more than one recipes" do
    it "should return recipe with closest use-by date" do
      expect do
        Rake.application.invoke_task('whats_for_dinner[all_fresh_ingredients.csv, two_recipes.json]')
      end.to output("Vegemite Sandwich\n").to_stdout
    end
  end

  context "with syntax error csv file" do
    it "should return error message" do
      expect do
        Rake.application.invoke_task('whats_for_dinner[syntax_error.csv, two_recipes.json]')
      end.to output("Invalid input files\n").to_stdout
    end
  end
end
