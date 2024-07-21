#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# RENAMING
$PSQL "ALTER TABLE properties RENAME COLUMN weight TO atomic_mass;
       ALTER TABLE properties RENAME COLUMN melting_point TO melting_point_celsius;
       ALTER TABLE properties RENAME COLUMN boiling_point TO boiling_point_celsius;"
       
# NOT NULL
$PSQL "ALTER TABLE properties ALTER COLUMN melting_point_celsius SET NOT NULL;
       ALTER TABLE properties ALTER COLUMN boiling_point_celsius SET NOT NULL;
       ALTER TABLE elements ALTER COLUMN symbol SET NOT NULL;
       ALTER TABLE elements ALTER COLUMN name SET NOT NULL;"

# UNIQUE
$PSQL  "ALTER TABLE elements ADD CONSTRAINT symbol_id UNIQUE (symbol);
        ALTER TABLE elements ADD CONSTRAINT name_id UNIQUE (name);"

# FOREIGN KEY
$PSQL "ALTER TABLE properties ADD CONSTRAINT fk_atomic_number FOREIGN KEY (atomic_number) REFERENCES elements (atomic_number) ON DELETE CASCADE;"

# FIXING PROPERTIES TYPE_ID ISSUES
$PSQL "ALTER TABLE properties ADD COLUMN type_id INT;
       UPDATE properties SET type_id = 1 WHERE type = 'metal';
       UPDATE properties SET type_id = 2 WHERE type = 'nonmetal';
       UPDATE properties SET type_id = 3 WHERE type = 'metalloid';

       ALTER TABLE properties ALTER COLUMN type_id SET NOT NULL;"

# CREATING TYPES TABLE
$PSQL "CREATE TABLE types(
       type_id SERIAL PRIMARY KEY,
       type VARCHAR(100) UNIQUE NOT NULL)"

# ADDING 3 ROWS TO TYPES
$PSQL "INSERT INTO types(type) VALUES('metal'),('nonmetal'),('metalloid'),('gas'),('halogen'),('actinides');"
       
# PROPERTIES TYPE_ID FOREIGN KEY
$PSQL "ALTER TABLE properties ADD CONSTRAINT fk_type FOREIGN KEY (type_id) REFERENCES types (type_id) ON DELETE CASCADE;"

# DROPING TYPE COLUMN FROM PROPERTIES
$PSQL "ALTER TABLE properties DROP COLUMN type;"

# FIXING CHARACTERS
PATTERN='^[a-z].*'
ELEMENTS=$($PSQL "SELECT atomic_number, symbol, name FROM elements")
echo "$ELEMENTS" | while IFS='|' read ATOMIC_NUMBER SYMBOL NAME
do
       SYMBOL=$(echo "$SYMBOL" | xargs)  # Trim whitespace
       if [[ $SYMBOL =~ $PATTERN ]]
       then
              NEW_SYMBOL=$(echo "$SYMBOL" | sed -E 's/^[a-z]/\u&/')
              $PSQL "UPDATE elements SET symbol = '$NEW_SYMBOL' WHERE atomic_number = $ATOMIC_NUMBER"
       fi
done

# FIXING ATOMIC_MASS NUMBER
$PSQL "ALTER TABLE properties ALTER COLUMN atomic_mass TYPE DECIMAL;"
ATOMIC_MASS=$($PSQL "SELECT * FROM properties ORDER BY atomic_number;")
echo "$ATOMIC_MASS" | while IFS='|' read ATOMIC_NUMBER ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS TYPE_ID
do
    cat atomic_mass.txt | while IFS='|' read ATOMIC_NUMBER_REFERENCE ATOMIC_MASS_REFERENCE
    do
       ATOMIC_NUMBER=$(echo "$ATOMIC_NUMBER" | xargs)
       ATOMIC_NUMBER_REFERENCE=$(echo "$ATOMIC_NUMBER_REFERENCE" | xargs)
       ATOMIC_MASS_REFERENCE=$(echo "$ATOMIC_MASS_REFERENCE" | xargs)

       if [[ $ATOMIC_NUMBER_REFERENCE != "atomic_number" && $ATOMIC_MASS_REFERENCE != "atomic_mass" ]]
       then
              if [[ $ATOMIC_NUMBER =~ $ATOMIC_NUMBER_REFERENCE ]]
              then
                     NEW_ATOMIC_MASS_REFERENCE=$(echo "$ATOMIC_MASS" | awk '{ printf "%.10g\n", $1 }')

                     $PSQL "UPDATE properties SET atomic_mass = $NEW_ATOMIC_MASS_REFERENCE WHERE atomic_number = $ATOMIC_NUMBER"
              fi
       fi
    done
done

# INSERTING DATA
$PSQL "INSERT INTO elements(atomic_number, symbol, name) VALUES(9, 'F', 'Fluorine');
       INSERT INTO properties(atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id) VALUES(9, 18.998, -220, -188.1, 2);
       INSERT INTO elements(atomic_number, symbol, name) VALUES(10, 'Ne', 'Neon');
       INSERT INTO properties(atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id) VALUES(10, 20.18, -248.6, -246.1, 2);"

# DELETING ATOMIC_NUMBER 1000
$PSQL "DELETE FROM elements WHERE atomic_number = 1000;"
