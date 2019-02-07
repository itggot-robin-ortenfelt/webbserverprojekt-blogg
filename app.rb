require 'sinatra'
require 'slim'
require 'sqlite3'
enable :sessions


get('/')do
    slim(:index)
end

post ('/login') do
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    result = db.execute("SELECT username, password FROM users WHERE users.username = (?)",params[:username])
    array = result[0] 
    if array == nil
        redirect('/')
    elsif params[:username] == array[0] && params[:password] == array[1]
            session[:loggedin] = true     
            redirect('/logined')
    else
        redirect('/nono')
    end
    
end

get('/logined') do
    if session[:loggedin] != true
        redirect('/nono')
    elsif session[:username] == params[:username]
        slim(:logined)
    else 
        redirect('/nono')
    end
end

get('/nono') do
    slim(:nono)
end

post ('/regNew') do 
    db = SQLite3::Database.new('db/db.db')
    db.execute("INSERT INTO users(username, password) VALUES((?), (?))",params[:reg_username], params[:reg_password])
    
    redirect('/')
end

get ('/reg')do
    slim(:reg)
end