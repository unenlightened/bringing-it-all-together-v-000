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
  end

  def self.create(name:, breed:)
   self.new(name, breed).tap {|song| song.save}
  end

  def self.find_by_id(id)
   sql = <<-SQL
      SELECT *
      FROM id
      WHERE name = ?
    SQL
   self.new_from_db(DB[:conn].execute(sql,id).flatten)
 end
end
