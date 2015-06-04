def db_connection
  begin
    connection = PG.connect(dbname: "recipes")
    yield(connection)
  ensure
    connection.close
  end
end

class Recipe
  attr_reader :id, :name, :instructions, :description, :ingredients
  def initialize(id, name, instructions, description, ingredients = nil)
    @id = id
    @name = name
    @instructions = instructions
    @description = description
    @ingredients = ingredients
  end

  def self.all
    recipe_list = db_connection do |conn|
      conn.exec("SELECT * FROM recipes;")
    end

    recipe_instances = []
    recipe_list.each do |recipe_info|
      recipe_instances << Recipe.new(recipe_info["id"], recipe_info["name"], recipe_info["instructions"], recipe_info["description"])
    end
    recipe_instances
  end

  def self.find(id)
    recipe_info = db_connection do |conn|
      sql_query ="SELECT recipes.name, recipes.instructions, recipes.description, ingredients.name AS ingredients FROM recipes JOIN ingredients ON recipes.id = ingredients.recipe_id WHERE recipes.id = $1"
      recipe_id = [id]

      conn.exec_params(sql_query, recipe_id)
    end

    name = recipe_info[0]["name"]
    instructions = recipe_info[0]["instructions"]
    description = recipe_info[0]["description"]
    ingredients = []
    recipe_info.each do |hash|
      ingredients << hash["ingredients"]
    end

    Recipe.new(id, name, instructions, description, ingredients)
  end

end
