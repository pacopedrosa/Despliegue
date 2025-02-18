# Despliegue Completo PPA

Este proyecto implementa una aplicación web completa con frontend en React, backend en Symfony y una base de datos MySQL, todo ello desplegado con Docker.

## Requisitos Previos

- Docker y Docker Compose instalados
- Git

## Configuración Inicial

### 1. Clonar el Repositorio



### 2. Configuración del Archivo .env

Crea un archivo `.env` en la raíz del proyecto con el siguiente contenido:
```bash
# Credenciales MySQL
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=PPA_BD
MYSQL_USER=alumnoDAW
MYSQL_PASSWORD=passPPA

# Configuración Backend
DATABASE_URL="mysql://alumnoDAW:passPPA@database:3306/PPA_BD"
APP_ENV=dev
APP_SECRET=your_secret_key_here
```

### 3. Certificados SSL

Los certificados SSL se generarán automáticamente en la primera ejecución en el directorio `web/certs/`. No es necesario realizar ninguna acción manual.

### 4. Iniciar la Aplicación
```bash
docker-compose up -d
```

## Acceso a los Servicios

Una vez iniciada la aplicación, podrás acceder a:

- Frontend: https://localhost
- PHPMyAdmin: http://localhost:8080
  - Usuario: alumnoDAW
  - Contraseña: passPPA
- API Backend: https://localhost/api/ppa

## Estructura del Proyecto

- `/frontend`: Aplicación React
- `/backend`: API Symfony
- `/web`: Configuración de Nginx y SSL
- `/database`: Scripts de inicialización de la base de datos

## Seguridad

- Los certificados SSL y el archivo .env están configurados para no subirse al repositorio
- Las credenciales de la base de datos solo son accesibles dentro de la red de Docker
- El proxy inverso (Nginx) gestiona todas las conexiones HTTPS

## Mantenimiento

Para detener la aplicación:
```bash
docker-compose down
```

Para reconstruir los contenedores:
```bash
docker-compose up -d --build
```

## Autor
- Paco Pedrosa Arjona














services:
  frontend:
    build:
      context: ./frontend
      dockerfile: DockerfileFrontendPPA
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - CHOKIDAR_USEPOLLING=true # Activa polling para asegurar detección de cambios en Docker
    depends_on:
      - backend
    networks:
      - app-network

  backend:
    build:
      context: ./backend
      dockerfile: DockerfileBackendPPA
    ports:
      - "8000:8000"
    volumes:
      - ./backend:/app
    depends_on:
      - database
    command: >
      sh -c "
      composer install &&
      composer show doctrine/dbal &&
      php -S 0.0.0.0:8000 -t public"
    networks:
      - app-network

  database:
    image: mysql:8.0
    # ports:
      # - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: PPA_BD
      MYSQL_USER: alumnoDAW
      MYSQL_PASSWORD: passPPA
    volumes:
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
      - database_data:/var/lib/mysql
    networks:
      - app-network

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    ports:
      - "8080:80"
    environment:
      PMA_HOST: database
      PMA_USER: alumnoDAW
      PMA_PASSWORD: passPPA
    depends_on:
      - database
    networks:
      - app-network

  web:
    build:
      context: ./web
      dockerfile: DockerfileWeb
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./web/certs:/etc/nginx/certs
    depends_on:
      - frontend
      - backend
    networks:
      - app-network

networks:
  # app-network:
    driver: bridge

volumes:
  database_data:
