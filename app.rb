require 'sinatra'
require 'slim'
require 'sqlite3'
require 'byebug'
enable :sessions


get('/')do
    slim(:index)
end

get('/login') do
    slim(:login)
end

post ('/login') do
    db = SQLite3::Database.new('db/bloggDatabase.db')
    db.results_as_hash = true
    result = db.execute("SELECT username, password, userId FROM Users WHERE users.username = (?)",params[:username])
    array = result[0] 

    if array == nil
        redirect('/')
    end
    userId = array[2]
    if params[:username] == array[0] && params[:password] == array[1]
            session[:loggedin] = true   
            session[:user_id] = userId   
            redirect("/profile/#{userId}")
    else
        redirect('/nono')
    end
    
end

get('/profile/:userId') do
    db = SQLite3::Database.new('db/bloggDatabase.db')
    db.results_as_hash = true 
    if session[:loggedin] != true
        redirect('/nono')
    elsif session[:username] == params[:username]
        result = db.execute("SELECT title, text FROM posts WHERE posts.userId = (?)", session[:user_id])
        slim(:profile, locals:{posts: result})
        
    else 
        redirect('/nono')
    end
end

get('/mainPage') do
    slim(:mainpage)
end

get('/nono') do
    slim(:nono)
end

post ('/regNew') do 
    db = SQLite3::Database.new('db/bloggDatabase.db')
    db.execute("INSERT INTO Users(username, password, email, parti) VALUES((?), (?), (?), (?))",params[:reg_username], params[:reg_password], params[:reg_email], params[:reg_parti])
    
    redirect('/')
end

get ('/register')do
    slim(:register)
end

post ('/newPost') do
    # anslut till db
    db = SQLite3::Database.new('db/bloggDatabase.db')
    db.results_as_hash = true 
    # plocka up parametrana från formuläret
    title = params["title"]
    text = params["text"]
    # skicka data tilldatabas med sql
    db.execute("INSERT INTO posts (text, title, userId) VALUES (?,?,?)",text,title, session[:user_id])
    # redirect till get
   
    redirect('/profile/:userId')
end

post ('/logout') do
    session.destroy
    redirect('/')
end