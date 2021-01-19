require'pry'
class Dog

    attr_accessor :id, :name, :breed

    def initialize(id: nil,name:,breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS #{self.create_table_name} (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.create_table_name
        self.to_s.downcase + "s"
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS #{self.create_table_name}"
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO #{self.class.create_table_name} 
        (name, breed)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql,self.name,self.breed )
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(name:,breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        @id,@name,@breed = row[0],row[1],row[2]
        Dog.new(id:@id,name:@name,breed:@breed)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * 
            FROM dogs
            WHERE dogs.id = ?
            LIMIT 1
            SQL
            DB[:conn].execute(sql,id).map do |row|
                self.new_from_db(row)
            end.first
    end

    def self.find_or_create_by(name:,breed:)
        sql = <<-SQL
            SELECT * 
            FROM dogs
            WHERE dogs.name = ?
            AND dogs.breed = ?
            SQL
            d = DB[:conn].execute(sql,name,breed)
            if !d.empty?
                dog = d[0]
                dogo = self.new(id:dog[0],name:dog[1],breed:dog[2])
            else
                dogo = self.create(name: name, breed: breed)
            end
            dogo
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            LIMIT 1
            SQL
            DB[:conn].execute(sql,name).map do |row|
                self.new_from_db(row)
            end.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ?  WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)

    end
    
end