#!/bin/bash
if [ $(id -u) -eq 0 ]
	then
		echo "Bienvanido a el script de dns"
		while true
			do
				echo -e "1.Configurar una zona maestra\n2.Configurar una zona esclava\n3.salir"
				read -p "Elige una opción: " opcion
				if [ $opcion -eq 1 ]
					then
						echo "Creando la zona directa...."
						sleep 2
						read -p "Dime el nombre de la zona: " n_zona
						zona="zone "
						zona+='"'
						zona+=$(echo $n_zona)
						zona+='." {'
						echo "$zona" >> "/etc/bind/named.conf.local"
						echo "type master;" >> "/etc/bind/named.conf.local"
						read -p "Introduce el número de redes en las que está permitida la búsqueda: " n_redes
						cont=0
						while [ $cont -lt $n_redes ]
							do
								read -p "Dime el nombre de red de la red $cont : " red
								redes+=$red
								redes+="; "
								cont=$(($cont+1))
							done
						n_archivo="/etc/bind/db.$n_zona"
						archivo='"'
						archivo+=$(echo $n_archivo)
						archivo+='";'
						echo "file ${archivo}" >> "/etc/bind/named.conf.local"
						echo "allow-query {$redes};" >> "/etc/bind/named.conf.local"
						echo "};" >> "/etc/bind/named.conf.local"
						echo ";" >> $n_archivo
						echo "; Archivo de zona para $n_zona" >> $n_archivo
						echo ";" >> $n_archivo
						zona2='$TTL    604800\n@       IN      SOA     '
						zona2+=$n_zona
						zona2+="."
						echo -e "$zona2 braulioperaltadelgado.gmail.com. (\n                               2         ; Serial\n                          604800         ; Refresh\n                           86400         ; Retry\n                         2419200         ; Expire\n                          604800 )       ; Negative Cache TTL" >> $n_archivo
						echo "; servidores de nombres" >> $n_archivo
						read -p "FQDN de el servidor de nombres (terminado en punto): " n_servidor
						echo "@       IN      NS      $n_servidor" >> $n_archivo
						read -p "Dime el numero de equipos de la red: " n_equipos
						cont=0
						echo "; registros a (equipos)" >> $n_archivo
						while [ $cont -lt $n_equipos ]
							do
								read -p "Dime el nombre de el equipo $cont: " equipo
								equipo+="       IN      A       "
								read -p "Dime la ip de el equipo $cont: " ip_equipo
								equipo+=$ip_equipo
								echo $equipo >> $n_archivo
								cont=$(($cont+1))
							done
						echo -e "¿Quieres crear alias a los equipos?\na) si\nb) no"
						read -p "Introduce una opcion: " opcion2
						while true
							do
								if [ $opcion2 == "a" ]
									then
										cont=0
										while [ $cont -lt $n_equipos ]
											do
												read -p "Dime el alias de el equipo $cont: " alias
												alias+="   IN      CNAME   "
												read -p "Indica el nombre de el equipo a el que va dirigido el alias: " equipo
												alias+=$equipo
												echo $alias >> $n_archivo
												cont=$(($cont+1))
											done
										break
								elif [ $opcion2 == "b" ]
									then
										echo "omitiendo la configuración de alias..."
										sleep 1
										break
								else
									echo "opcion no válida"
								fi
							done
						if [ $(named-checkzone $n_zona $n_archivo | tail -1) == "OK" ] 
							then 
								echo "La configuración de la zona se ha realizado de forma correcta" 
						else 
							echo "ERR la configuración de zona no se ha realizado correctamente contacte con el creador de el script braulioperaltadelgado@gmail.com" 
							break 
						fi
						echo "Configurando la zona inversa...."
						sleep 2
						read -p "Introduce la direccion o nombre de red al revés: " n_zona
						zona="zone "
						zona+='"'
						zona+=$(echo $n_zona)
						zona+='.in-addr.arpa." {'
						echo "$zona" >> "/etc/bind/named.conf.local"
						echo "type master;" >> "/etc/bind/named.conf.local"
						read -p "Introduce el número de redes en las que está permitida la búsqueda: " n_redes
						cont=0
						while [ $cont -lt $n_redes ]
							do
								read -p "Dime el nombre de red de la red $cont : " red
								redes+=$red
								redes+="; "
								cont=$(($cont+1))
							done
						n_archivo="/etc/bind/db.$n_zona"
						archivo='"'
						archivo+=$(echo $n_archivo)
						archivo+='";'
						echo "file ${archivo};" >> "/etc/bind/named.conf.local"
						echo "allow-query {$redes};" >> "/etc/bind/named.conf.local"
						echo "};" >> "/etc/bind/named.conf.local"
						echo ";" >> $n_archivo
						echo "; Archivo de zona inversa para $n_zona" >> $n_archivo
						echo ";" >> $n_archivo
						echo "; servidor de nombres" >> $n_archivo
						zona2='$TTL    604800\n@       IN      SOA     '
						zona2+=$n_zona
						zona2+=".in-addr.arpa."
						echo -e "$zona2 braulioperaltadelgado.gmail.com. (\n                               2         ; Serial\n                          604800         ; Refresh\n                           86400         ; Retry\n                         2419200         ; Expire\n                          604800 )       ; Negative Cache TTL" >> $n_archivo
						echo "@       IN      NS      $n_servidor" >> $n_archivo
						echo "; registros ptr" >> $n_archivo
						cont=0
						while [ $cont -lt $n_equipos ]
							do
								read -p "Dime el  último octeto de la ip de el equipo $cont: " equipo
								equipo+="       IN      PTR       "
								read -p "FQDN del equipo $cont: " fqdn
								equipo+=$fqdn
								equipo+="."
								echo $equipo >> $n_archivo
								cont=$(($cont+1))
							done
						if [ $(named-checkzone $n_zona $n_archivo | tail -1) == "OK" ] 
							then 
								echo "La configuración de la zona se ha realizado de forma correcta" 
						else 
							echo "ERR la configuración de zona no se ha realizado correctamente contacte con el creador de el script braulioperaltadelgado@gmail.com" 
							break 
						fi
				elif [ $opcion -eq 2 ]
					then
						echo "Configurando la zona directa...."
						sleep 2
						read -p "Introduce la direccion o nombre de red al revés: " n_zona
						zona='"'
						zona+=$(echo $n_zona)
						zona+='.in-addr.arpa." {'
						echo "$zona" >> "/etc/bind/named.conf.local"
						echo "type slave;" >> "/etc/bind/named.conf.local"
						read -p "Introduce la dirección ip de el servidor master: " master
						master+=";"
						echo "masters {$master};" >> "/etc/bind/named.conf.local"
						read -p "Introduce el número de redes en las que está permitida la búsqueda: " n_redes
						cont=0
						while [ $cont -lt $n_redes ]
							do
								read -p "Dime el nombre de red de la red $cont : " red
								redes+=$red
								redes+="; "
								cont=$(($cont+1))
							done
						n_archivo="/etc/bind/db.$n_zona"
						archivo='"'
						archivo+=$(echo $n_archivo)
						archivo+='";'
						echo "file ${archivo};" >> "/etc/bind/named.conf.local"
						echo "allow-query {$redes};" >> "/etc/bind/named.conf.local"
						echo "};" >> "/etc/bind/named.conf.local"
						echo "Configurando la zona inversa..."
						sleep 2
						read -p "Introduce la direccion o nombre de red al revés: " n_zona
						zona='"'
						zona+=$(echo $n_zona)
						zona+='.in-addr.arpa." {'
						echo "$zona" >> "/etc/bind/named.conf.local"
						echo "type slave;" >> "/etc/bind/named.conf.local"
						read -p "Introduce la dirección ip de el servidor master: " master
						master+=";"
						echo "masters {$master};" >> "/etc/bind/named.conf.local"
						read -p "Introduce el número de redes en las que está permitida la búsqueda: " n_redes
						cont=0
						while [ $cont -lt $n_redes ]
							do
								read -p "Dime el nombre de red de la red $cont : " red
								redes+=$red
								redes+="; "
								cont=$(($cont+1))
							done
						n_archivo="/etc/bind/db.$n_zona"
						archivo='"'
						archivo+=$(echo $n_archivo)
						archivo+='";'
						echo "file ${archivo};" >> "/etc/bind/named.conf.local"
						echo "allow-query {$redes};" >> "/etc/bind/named.conf.local"
						echo "};" >> "/etc/bind/named.conf.local"
				elif [ $opcion -eq 3 ]
					then
						break
				else
					echo "ERR:Opcion no válida"
				fi
			done
else
	echo "ERR:El script debe ejecutarse con root"
fi
