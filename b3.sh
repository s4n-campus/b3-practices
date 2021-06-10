#!/bin/bash
## Ayudante para los ejercicios prácticos de los microcursos basicos 3.

echo "¡Hola! Bienvenido a los ejercicios prácticos del micro curso de resiliencia."
echo "Antes de empezar vamos a preparar el ambiente. asegurate de tener instalado docker, docker-compose y curl"
read -p "Presiona enter cuando estes listo."
echo "Listo vamos a iniciar el ambiente, recuerda que estamos en modo beta y si encuentras un error debes reportarlo al equipo de S4N Campus."
docker-compose -f resilience/docker-compose.yml up -d
docker-compose -f resilience/docker-compose.yml exec toxiproxy sh -c "/go/bin/toxiproxy-cli create dummy_bank -l toxiproxy:10000 -u dummy_services:8000"
docker-compose -f resilience/docker-compose.yml exec toxiproxy sh -c "/go/bin/toxiproxy-cli create dummy_qr -l toxiproxy:10001 -u dummy_services:8000"
if [ "$?" -eq "0" ]
then 
    echo "¡Todo listo! Ahora puedes escribir tu código y cuando estes listo regresa y elige una opción. "
    PS3='¿qué quieres hacer? '
    options=("Probar el servicio del banco" "Probar el servicio de generación de QR" "Probar mi servicio" "Hacer el banco lento" "Salir")
    select opt in "${options[@]}"
    do
        case $opt in
            "Probar el servicio del banco")
                echo ""
                echo "Vamos a realizar una petición HTTP POST al servicio del banco(http://172.17.0.1:10000/fake-bank) con el siguiente payload"
                echo '{"creditCard":{"number":"5555 5555 5555 4444","cvc":"1230","expiresDate":{"year":"30","month":"12"}},"amount":10}'
                echo "invocando..."
                echo ""
                curl --data '{"creditCard":{"number":"5555 5555 5555 4444","cvc":"1230","expiresDate":{"year":"30","month":"12"}},"amount":10}' http://172.17.0.1:10000/fake-bank
                echo ""
                echo ""
                ;;
            "Probar el servicio de generación de QR")
                echo ""
                echo "Vamos a realizar una petición HTTP GET al servicio de generacion de qr (http://172.17.0.1:10001/qr-generator/1:321dc3da-be75-4e58-9af0-57f615d6de3a)"
                echo "invocando..."
                echo ""
                curl http://172.17.0.1:10001/qr-generator/321dc3da-be75-4e58-9af0-57f615d6de3a
                echo ""
                echo ""
                ;;
            "Probar mi servicio")
                echo ""
                echo "Vamos a realizar una petición HTTP POST al servicio (http://localhost:8080/student-tickets-store/buy-event) con el siguiente payload"
                echo '{"eventid":"1","card":"5555 5555 5555 4444","cvc":"1230","expiresDate":"3012"}'
                echo "invocando..."
                echo ""
                curl -d '{"eventId":"1","card":"5555 5555 5555 4444","cvc":"1230","expiresDate":"3012"}' -H 'Content-Type: application/json' http://localhost:8080/student-tickets-store/buy-event
                echo ""
                echo ""
                ;;
            "Hacer el banco lento")
                echo ""
                echo "Vamos a hacer el banco lento."
                docker-compose -f resilience/docker-compose.yml exec toxiproxy sh -c "/go/bin/toxiproxy-cli toxic add dummy_bank -t latency -a latency=3000"
                echo ""
                echo ""
                ;;
            "Salir")
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
else
    echo "Ocurrió un error que no previmos por favor reportalo al equipo de campus. No olvides incluir el log de error."
    read -p "Presiona enter para continuar..."
fi

docker-compose -f resilience/docker-compose.yml stop
docker-compose -f resilience/docker-compose.yml rm --force

echo "Hemos apagado el ambiente de prueba. Esperamos hayas disfrutado el reto."