class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize (name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = 'DROP TABLE IF EXISTS dogs'
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
       SQL
       DB[:conn].execute(sql, self.name, self.breed)
       @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    self.new(name: name, breed: breed).save
  end

  def self.find_or_create_by(name:, breed:)
      row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten
    if !row.empty?
      dog = self.new_from_db(row)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

 def self.new_from_db(row)
   id, name, breed = row
   self.new(name: name, breed: breed, id: id)
 end

 def self.find_by_name(name)
   sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
   self.new_from_db(DB[:conn].execute(sql, name).flatten)
 end

 def self.find_by_id(id)
   sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, id.to_s).flatten)
 end

 def update
   sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?'
   DB[:conn].execute(sql, self.name, self.breed, self.id)
 end
end
