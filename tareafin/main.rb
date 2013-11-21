

require "rubygems" #libreria para usar programas gems
require 'oauth'
require 'hpricot' #libreria para machetear un html
require 'open-uri'
require "sinatra"
require 'erb'

$Url1; 
	
$Titulo1;
$Autor1;

class DatosDePagina
	attr_accessor :titulo, :artista, :link, :derecho
end



get '/' do

        erb :Inicio
	
end 


def actualiza()


        lista = @lista_grupos
	i=(lista.length-1)
	puts ("El tweet %s sera" % (i+1))
	puts lista[i].artista 
	puts lista[i].titulo
	puts lista[i].derecho 
	puts lista[i].link
		puts ("\n" )
	
$Url1=lista[i].link;
	
$Titulo1=lista[i].derecho;
$Autor1=lista[i].artista; 

	
	
	     
         

         redirect '/Result'
        
        
        
        
end

post '/bandcamp' do



        tag=""
	tag= params[:campo1]
        
        

	 #Metodo que se encarga de sacar la informacion del HTML, con ayuda de la biblioteca hpricot y open-uri

	@lista_grupos = []
	link = (("http://bandcamp.com/tag/"+tag).gsub(" ","-")).downcase
	pagina = ''
	#Accesa el link
	open(link) { |f| pagina = f.read}
	#Guarda los datos de la página en la variable datospagina
	strpagina = Hpricot(pagina)
	puts "Buscando resultados en la pagina..."

	for i in 1..10 do
		begin
		puts ("Cargando el resultado %s" % i)
		infoABuscar = "#content.tags > div.leftcolumn > div.results_area > div.results > ul.item_list > li:nth(%s)" % i 			#Tags de HTML a buscar
 		#rindex retorna la posición del string proporcionado
		#Extrae el codigo y lo guarda en un string para analizarlo
		str = strpagina.at(infoABuscar).inner_html
		grupo = DatosDePagina.new
		#NombreArtista
		inicio = str.rindex('"')
		fin = str.rindex('<')
		grupo.artista = str[(inicio + 2)..(fin-1)].gsub("&amp;","&")
		#Titulo
		for j in 1..8 do
			inicio = str.rindex('"',(inicio-1))
		end
		inicio2 = str.rindex('"',(inicio-1))
		grupo.titulo = str[(inicio2 + 1)..(inicio-1)].gsub("&amp;","&")
		#Link 
		inicio = str.rindex('"',(inicio2-1))
		inicio2 = str.rindex('"',(inicio-1))
		grupo.link = str[(inicio2 + 1)..(inicio-1)]
		
		#Esta parte ingresa a la página de la canción escogida para ver si es paga o no		
		pagina2 = ''
		#Accesa el link
		open(grupo.link) { |f| pagina2 = f.read}
		#Guarda el HTML de la pagina de la cancion, para poder saber si es paga o comprada
		strpagina2 = Hpricot(pagina2)
		infoABuscar = "#trackInfoInner > ul.tralbumCommands > li.buyItem > h4.ft" #Tags de HTML que se buscaran
		begin
			str = strpagina2.at(infoABuscar).inner_html
			grupo.derecho = str[83,3]
			if grupo.derecho == "Free"
				grupo.derecho = "Free"
			else grupo.derecho == "Buy"
				grupo.derecho = "Paid"
			end
			rescue Exception => e
				grupo.derecho = "Free"
	
		end
			rescue Exception => e
			if @lista_grupos.length == 0
				abort ("No hay ningun resultado para esta busqueda")
			else
				puts "\n"
				puts "No hay mas resultados con las palabras de busqueda"
				puts "\n"
				break
			end
	end
		@lista_grupos << grupo #Guarda el resultado en la lista global
	end
	puts ("Resultados cargados \n")

actualiza()
	
end	




# Metodo get que direcciona a la cuadricula de resultados
get '/Result' do

        erb :Resultados

end

# Metodo get que llama a la pagina especial de error en caso de no enNum_de_fotorar resultados a la busqueda
get '/No_result' do

        erb :SinResultados

end


class Autentificar


def conectar 
 puts <<EOS
Set up your application at https://twitter.com/apps/ (as a 'Client' app),
then enter your 'Consumer key' and 'Consumer secret':
 
Consumer key:
EOS
consumer_key = STDIN.readline.chomp
puts "Consumer secret:"
consumer_secret = STDIN.readline.chomp
 
consumer = OAuth::Consumer.new(
consumer_key,
consumer_secret,
{
:site=>"http://twitter.com",
        :request_token_url=>"https://api.twitter.com/oauth/request_token",
        :access_token_url =>"https://api.twitter.com/oauth/access_token",
        :authorize_url =>"https://api.twitter.com/oauth/authorize"
})
 
request_token = consumer.get_request_token
 
puts <<EOS
Visit #{request_token.authorize_url} in your browser to authorize the app,
then enter the PIN you are given:
EOS
 
pin = STDIN.readline.chomp
access_token = request_token.get_access_token(:oauth_verifier => pin)
 
puts <<EOS
Congratulations, your app has been granted access! Use the following config:
 
TWITTER_CONSUMER_KEY = '#{consumer_key}'
TWITTER_CONSUMER_SECRET = '#{consumer_secret}'
TWITTER_ACCESS_TOKEN = '#{access_token.token}'
TWITTER_ACCESS_SECRET = '#{access_token.secret}'
 
And use the following code to connect to Twitter:
 
require 'twitter'
auth = Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
auth.authorize_from_access(TWITTER_ACCESS_TOKEN, TWITTER_ACCESS_SECRET)
client = Twitter::Base.new(auth)
 
EOS
   end
end 



def iniciar #inicia autentificacion
   begin
   autentificar=Autentificar.new()
   autentificar.conectar
   rescue => e
      puts "Error: La operacion de autentificacion fallo!"
   end
end
                        


iniciar







  

