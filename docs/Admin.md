Администрирование образов
____

Проект состоит из 4х частей:
## POSTGRES

Независимая часть, это postgresql все взято с https://github.com/VanessaDockers/pgsteroids, дополнительно сделана доработка по установке прав на папку PGDATA, что-бы корректно работал перезапуск postgres. Запуск делается с помощью указания доп.параметров и переменных окружений. 

### Environment Variables

The PostgreSQL image uses several environment variables which are easy to miss. While none of the variables are required, they may significantly aid you in using the image.

#### `POSTGRES_PASSWORD`

This environment variable is recommended for you to use the PostgreSQL image. This environment variable sets the superuser password for PostgreSQL. The default superuser is defined by the `POSTGRES_USER` environment variable. In the above example, it is being set to "mysecretpassword".

#### `POSTGRES_USER`

This optional environment variable is used in conjunction with `POSTGRES_PASSWORD` to set a user and its password. This variable will create the specified user with superuser power and a database with the same name. If it is not specified, then the default user of `postgres` will be used.

#### `PGDATA`

This optional environment variable can be used to define another location - like a subdirectory - for the database files. The default is `/var/lib/postgresql/data`, but if the data volume you're using is a fs mountpoint (like with GCE persistent disks), Postgres `initdb` recommends a subdirectory (for example `/var/lib/postgresql/data/pgdata` ) be created to contain the data.

#### `POSTGRES_DB`

This optional environment variable can be used to define a different name for the default database that is created when the image is first started. If it is not specified, then the value of `POSTGRES_USER` will be used.

#### `POSTGRES_INITDB_ARGS`

This optional environment variable can be used to send arguments to `postgres initdb`. The value is a space separated string of arguments as `postgres initdb` would expect them. This is useful for adding functionality like data page checksums: `-e POSTGRES_INITDB_ARGS="--data-checksums"`.

#### `PGENCODING` 
Указывается кодировка при инициализации базы данных, необходимо для указания создании кодировки базы. Кодировка указывается в формате uk_UA.UTF-8 , а при созании базы на сервере 1С необходимо указывать краткое название кодировки uk,ru,en...

## `CORE-32bit\XENIAL`

Копия официального создания базовых образов ubuntu для docker. Во всех скриптах только замененно amd64 на i386. Генерация образа происходит с помощью выполнения команды `update.sh xenial` будет скачан cloud образ ubuntu и как rootfs будет использоваться для построения базового образа. В результате будет образ `ubuntu32:16.04` и он же `ubuntu32:xenial`

## `BASE` 

Подготавливает базовые образы для установки самой 1С. Зависит от `ubuntu32:xenial` и устанавливает необходимые пакеты для запуска сервера и клиента 1С. Скрипт запуска `base/build.sh`  и результатом должно появится 2 образа `one/32bit/baseimage:latest`, `one/32bit/baseclient:latest` 

## `ONEC` 

Каталог построен по аналогии с базовыми образами docker. Запускаем `update.sh 8.3.10.2022` скрипт делает копию с каталога base в каталог с номером версии и собирает этот базовый образ, предварительно в каталоге `./dist/{version}/` проверяется наличие 32 битных архивов платофрмы для deb, если такого каталога не существует, тогда попытается его скачать, для указание пользователя и пароля необходимо определить переменные окружения `V8USER,V8PASSW` примерный запуск команды будет выглядеть так 
`V8PASSW=passs V8USER=user update.sh 8.3.10.2022` 
Результатом выполнения скрипта будет создание двух image `onec32/client:{version}` `onec32/server:{version}` 


Для запуска образов используется указание что запускать параметром командной строки: 
`ragent`, `cserver`, `apache` `client` 


### Environment Variables

Скрипт запуска 1С предполагает возможность переопределить различные параметры запуска, через переменные окружения. Все параметры имеют значение по умолчанию. Входная точка для запуска и анализа это `/distr/docker-entrypoint.sh` 

#### `TIMEZONE`

указание 