# Аргументы для Compose, определяемые по умолчанию
COMPOSE_ARGS=" -f identidock/docker-compose-jenkins.yml -p jenkins "
# Необходимо остановить и удалить все старые контейнеры
sudo docker-compose $COMPOSE_ARGS stop
sudo docker-compose $COMPOSE_ARGS rm --force -v
# Создание (сборка) системы
sudo docker-compose $COMPOSE_ARGS build --no-cache
# Выполнение модульного тестирования
sudo docker-compose $COMPOSE_ARGS run --no-deps --rm -e ENV=UNIT identidock #берем наш собранный образ  и запускаем только одинокий(т.к. --no-deps) контейнер identidock с переменной окржения UNIT и  
# Выполнение тестирования системы в целом, если модульное тестирование завершилось успешно
ERR=$? #код завершения последней операции

if [ $ERR -eq 0 ]; then
	#Запуск продакш сборки identidock
	sudo docker-compose $COMPOSE_ARGS up -d
    
    IP=$(
        sudo docker inspect -f {{.NetworkSettings.IPAddress}} jenkins_identidock_1
    )
    CODE=$(curl -sL -w "%{http_code}" $IP:9090/monster/bla -o /dev/null) || true
    #вывод в файл /dev/null - говорит о том что нам не важен вывод операции и мы грубо говря хотим его удалить
    if [ $CODE -ne 200 ]; then
        echo "Site returned " $CODE
        ERR=1
    fi
fi
# Останов и удаление системы
sudo docker-compose $COMPOSE_ARGS stop
sudo docker-compose $COMPOSE_ARGS rm --force -v
return $ERR