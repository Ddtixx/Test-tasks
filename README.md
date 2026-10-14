# Nginx Test Task

Тестовое задание: развернуть Nginx на VM, настроить firewall,
написать Bash-скрипт проверки доступности с логированием.

# Краткое описание 
- Ansible разворачивает Nginx, настраивает ufw и скрипт проверки на VM 
- Bash-script проверяте доступность страницы как локально так и снаружи пишет результат с датой и временем в `/var/log/nginx_check.log`
- Cron запускает проверку доступности страницы каждые 5 минут

# Требования

- Ansible 2.15+
- Коллекция `community.general`
- SSH-доступ к целевой VM

# Быстрый старт

1. Скопировать `inventory.ini.example` в `inventory.ini`, указать хост:
   ```bash
   cp inventory.ini.example inventory.ini
   nano inventory.ini```
2. Копировать host_vars/node1.yml.example в host_vars/node1.yml
   и заменить <YOUR_PUBLIC_IP> на реальный публичный IP сервера:
   ```bash
   cp host_vars/node1.yml.example host_vars/node1.yml
   nano host_vars/node1.yml

3. Запустить плейбук:
   ```bash 
   ansible-playbook -i inventory.ini playbook.yml --diff```
4. Проверить доступность сайта:
   ```bash
   curl -I http://<YOUR_PUBLIC_IP>```

5. Проверить открытые и закрытые порты через nmap:
   ```bash
   nmap -p 22,80,443,3306,5432 <YOUR_PUBLIC_IP>```
 
# Структура плейбука

Роль:	        Что делает:
ufw	        Firewall: разрешает только SSH (22/tcp) и HTTP (80/tcp), входящий по умолчанию запрещён
nginx	        Устанавливает Nginx, разворачивает статическую страницу, запускает сервис
check_script	Устанавливает Bash-скрипт проверки, создаёт cron-задания (локальная и публичная проверки)


# Что делает скрипт
Bash-скрипт проверки

Скрипт check_nginx.sh устанавливается в /usr/local/bin/ и запускается
через cron каждые 5 минут. Что делает:

- Делает HTTP-запрос к заданному URL (по умолчанию http://127.0.0.1/).

- Сравнивает HTTP-код с ожидаемым (200).

- Пишет результат в лог с датой и временем:
  Пример:
  2026-10-14 17:20:01 SUCCESS http_code=200 url=http://127.0.0.1/
  2026-10-14 17:23:14 FAILURE http_code=000 url=http://127.0.0.1/

- Возвращает код 0 при успехе, 1 при ошибке.

URL задаётся через переменную окружения URL, поэтому один скрипт
используется для двух проверок:

Локальная (http://127.0.0.1/) — проверяет, что Nginx отвечает.

Публичная (http://<YOUR_PUBLIC_IP>/) — проверяет, что сайт доступен снаружи
(учитывает firewall и сеть).

