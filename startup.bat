call C:\Ruby200-x64\bin\setrbvars.bat
start "MongoDB" "C:\Program Files\MongoDB 2.6 Standard\bin\mongod" --dbpath="..\mongo"
start "FuzzySeal" "ruby" lib\daemon\FuzzySeal.rb
start "PACTO_UltraView" "rails" s