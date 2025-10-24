# Deploy Pyrrha with Docker Compose

Docker Compose is a tool for defining and running multi-container Docker applications. The Pyrrha project consists of the following services.

- **pyrrha-mariadb**: the database that holds all the Pyrrha data
- **pyrrha-wss**: the WebSocket server
- **pyrrha-mqttserver**: an MQTT broker service that uses VerneMQ
- **pyrrha-mqttclient**: the service that sits between the IoT platform and other services
- **pyrrha-rulesdecision**: the analytics service that calculates the time weighted averages of all data
- **pyrrha-api-main**: the API backend for the dashboard
- **pyrrha-api-auth**: the API backend used for authentication
- **pyrrha-dashboard:** the dashboard that shows the real-time and long-term averages of firefighter exposure to toxic gases

> Note: This environment does not set up the smartphone or watch apps.

The `docker-compose.yaml` file defines and configures all of these services.

- [Prerequisites](#prerequisites)
  - [Locally on your machine](#locally-on-your-machine)
  - [IBM Cloud](#ibm-cloud)
- [Configuration](#configuration)
  - [pyrrha-mariadb](#pyrrha-mariadb)
  - [pyrrha-wss](#pyrrha-wss)
  - [pyrrha-mqttserver](#pyrrha-mqttserver)
  - [pyrrha-mqttclient](#pyrrha-mqttclient)
  - [pyrrha-rulesdecision](#pyrrha-rulesdecision)
  - [pyrrha-api-main](#pyrrha-api-main)
  - [pyrrha-api-auth](#pyrrha-api-auth)
  - [pyrrha-dashboard](#pyrrha-dashboard)
  - [pyrrha-simulator](#pyrrha-simulator)
- [Deployment](#deployment)

## Prerequisites

### Locally on your machine

- [Docker](https://docs.docker.com/engine/install/)

  - Ensure you have docker installed by using `docker --version` command. You should see output as follows:

    ```bash
    Docker version 19.03.13, build 4484c46d9d
    ```

- [Docker Compose](https://docs.docker.com/compose/install/)

  - Docker Compose is a plugin that comes as a part of Docker Desktop. You can verify this by running `docker` and checking the Management Commands section. On Linux, you will need to follow the instructions to install Compose, available at the link above.

### IBM Cloud

- Sign up for an [IBM Cloud account](https://cloud.ibm.com/registration).
- Create [IBM App ID service](https://cloud.ibm.com/catalog/services/app-id) and make note of the credentials.

## Configuration

1. Create a directory called `pyrrha`. This is where the rest of the code will be cloned.

   ```bash
   mkdir pyrrha && cd pyrrha
   ```

1. Create a [fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) for each of the following required repositories:

- [Pyrrha-Deployment-Configurations](https://github.com/Pyrrha-Platform/Pyrrha-Deployment-Configurations)
- [Pyrrha-Dashboard](https://github.com/Pyrrha-Platform/Pyrrha-Dashboard)
- [Pyrrha-WebSocket-Server](https://github.com/Pyrrha-Platform/Pyrrha-WebSocket-Server)
- [Pyrrha-Rules-Decision](https://github.com/Pyrrha-Platform/Pyrrha-Rules-Decision)
- [Pyrrha-MQTT-Client](https://github.com/Pyrrha-Platform/Pyrrha-MQTT-Client)
- [Pyrrha-Database](https://github.com/Pyrrha-Platform/Pyrrha-Database)
- [Pyrrha-Sensor-Simulator](https://github.com/Pyrrha-Platform/Pyrrha-Sensor-Simulator)

1. Clone all the newly created forks, using your GitHub username instead of `YOUR_USERNAME`

   ```bash
   git clone https://github.com/YOUR_USERNAME/Pyrrha-Deployment-Configurations.git &&
   git clone https://github.com/YOUR_USERNAME/Pyrrha-Dashboard.git &&
   git clone https://github.com/YOUR_USERNAME/Pyrrha-WebSocket-Server.git &&
   git clone https://github.com/YOUR_USERNAME/Pyrrha-Rules-Decision.git &&
   git clone https://github.com/YOUR_USERNAME/Pyrrha-MQTT-Client.git &&
   git clone https://github.com/YOUR_USERNAME/Pyrrha-Database.git &&
   git clone https://github.com/YOUR_USERNAME/Pyrrha-Sensor-Simulator.git
   ```

1. Set MariaDB password in your terminal. This will be used with the rest of the instructions.

   ```bash
   export MDB_PASSWORD=example
   ```

   Optionally, you can add this line to `.bashrc` or `.zshrc` file so it is automatically set whenever a terminal is opened.

Let's configure each of the services.

### pyrrha-mariadb

1. Ensure you set `MDB_PASSWORD` variable in the same terminal you will run the solution.

### pyrrha-wss

1. No additional configuration required

### pyrrha-mqttserver

Pyrrha Platform makes use of VerneMQ as its MQTT broker of choice. It is high performance, open source, supports authentication, and supports containers and Kubernetes. More information can be found at [their website](https://vernemq.com/).

By default, the broker is configured to use database authentication. You can see the configuration in the `docker-compose.yaml` file under `pyrrha-mqttserver` > `environment`.
It is recommended to leverage authentication for this service so only applications and devices you control can access the MQTT broker service.

A database table is included in the MariaDB configuration called `vmq_auth_acl`. This is the required table for the broker service to authenticate against. You can read more details about it [here](https://docs.vernemq.com/configuring-vernemq/db-auth#mysql).

### pyrrha-mqttclient

The first step for configuration is to create a record in the `vmq_auth_acl` table as was mentioned in the MQTT broker section. In order to do this:

- Ensure the `MDB_PASSWORD` variable is set in your command line session.

- Ensure that you have the Docker Desktop app running.

Change directory to your pyrrha/Pyrrha-Deployment-Configurations directory.

- Run the following command. This will start the database service. `docker compose up -d pyrrha-mariadb`
  - Note: if you run into the error message `Error response from daemon: invalid mount config for type "bind": bind source path does not exist: PATH_TO_PYRRHA_DIR/pyrrha/Pyrrha-Database/data`, run `mkdir data` in your `pyrrha/Pyrrha-Database/` directory.

- Run the following command to get the ID of the running container for `pyrrha-mariadb`. `docker container ls`

- Run this command to enter into the running `pyrrha-mariadb` container. Replace `CONTAINERID` with the ID found in the last step. `docker exec -it CONTAINERID /bin/bash`

- Once in the container, run the following command. This will enter you into the MariaDB session. `mysql -uroot -p`. You will need the `MDB_PASSWORD` value.

- Once in the database service, you can check which databases are available with `show databases;` (note the semicolon). Ensure `pyrrha` shows in the list. Run `use pyrrha;` (note the semicolon) to switch to that database.

- Verify that the `vmq_auth_acl` table exists first using `show tables;`. If it does not, run the follow SQL statement before continuing. Note: this is the same `CREATE TABLE` statement referenced in the VerneMQ documentation.

```sql
CREATE TABLE vmq_auth_acl
(
  mountpoint VARCHAR(10) NOT NULL,
  client_id VARCHAR(128) NOT NULL,
  username VARCHAR(128) NOT NULL,
  password VARCHAR(128),
  publish_acl TEXT,
  subscribe_acl TEXT,
  CONSTRAINT vmq_auth_acl_primary_key PRIMARY KEY (mountpoint, client_id, username)
);
```

- You will need to run an INSERT statement similar to the following. You will fill in the `CLIENTID`, `USERNAME`, and `PASSWORD` items yourself. Also make note of these 3 pieces of information as they will be used to fill in values in `Pyrrha-MQTT-Client/.env.docker`.

```sql
INSERT INTO vmq_auth_acl(mountpoint, client_id, username, password, subscribe_acl) VALUES ('', 'CLIENTID', 'USERNAME', SHA2('PASSWORD', 256), '[{"pattern":"iot-2/#"}]');
```

- After successful insert, you can verify the data was inserted by running `SELECT * FROM vmq_auth_acl;` to see the information. When finished, you can type `\q` and press ENTER to leave the mysql console.

- Type `exit` and press ENTER to leave the container.

---

Next, open the `Pyrrha-MQTT-Client/.env.docker` file.

1. Fill in the values in `Pyrrha-MQTT-Client/.env.docker` file. You need to fill out:

   - `IOT_CLIENTID`, `IOT_USERNAME`, and `IOT_PASSWORD` with the values entered in the last steps.

   You can leave the rest of the values the same:

   ```bash
   IOT_HOST=pyrrha-mqttserver
   IOT_TOPIC='iot-2/#'
   IOT_PROTOCOL=mqtt
   IOT_PORT=1883
   IOT_SECURE_PORT=1883
   IOT_CLIENTID=someclientid
   IOT_USERNAME=
   IOT_PASSWORD=
   ```

   Leave the database section as follows:

   ```bash
   MARIADB_HOST=pyrrha-mariadb
   MARIADB_PORT=3306
   MARIADB_USERNAME=root
   MARIADB_PASSWORD=$MDB_PASSWORD
   MARIADB_DB=pyrrha
   ```

   Leave the websocket server section as follows:

   ```bash
   WS_HOST=pyrrha-wss
   WS_PORT=8080
   ```

### pyrrha-rulesdecision

1. Ensure the `Pyrrha-Rules-Decision/src/.env.docker` file contains the following variables:

   ```bash
   MARIADB_HOST=pyrrha-mariadb
   MARIADB_PORT=3306
   MARIADB_USERNAME=root
   MARIADB_PASSWORD=$MDB_PASSWORD
   MARIADB_DB=pyrrha
   ```

### pyrrha-api-main

1. Ensure the `Pyrrha-Dashboard/pyrrha-dashboard/api-main/.env.docker` file contains the following variables:

   ```bash
   MARIADB_HOST=pyrrha-mariadb
   MARIADB_PORT=3306
   MARIADB_USERNAME=root
   MARIADB_PASSWORD=$MDB_PASSWORD
   MARIADB_DB=pyrrha
   ```

### pyrrha-api-auth

1. The authorization service uses IBM Cloud App ID service for authentication and authorization. Make a copy of the `vcap-local.template.json` file located in the `Pyrrha-Dashboard/pyrrha-dashboard/api-auth` directory and rename it `vcap-local.json` (this file is ignored by Git) using this command:

   ```bash
   # from the root directory
   cp ./Pyrrha-Dashboard/pyrrha-dashboard/api-auth/vcap-local.template.json Pyrrha-Dashboard/pyrrha-dashboard/api-auth/vcap-local.json
   ```

2. Provision an AppID instance in IBM Cloud - <https://cloud.ibm.com/catalog/services/app-id>
3. Create AppID service credentials: In the newly created AppID instance, go to Service Credentials -> New credential. Set the role to `Writer`.
4. Expand the created credentials and fill in the required properties in your `vcap-local.json` file located in `web/api` under `AppID` and `credentials`.
For `name` under `credentials` you can use the `iam_apikey_name` value from the created credential. You can leave the `scopes` field as an empty array.
5. Copy the `apiKey` from your service credentials and add it to `vcap-local.json` in the `api_key` field under `ibm_cloud`.
6. `session_secret` under `user_vars`: this can be any random string of characters.
7. `pyrrha_api_key` under `user_vars`: this can be any random string of characters. This is used to send authenticated requests to the API.
8. `jwt_secret` under `user_vars`: this can be any random string of characters.

### pyrrha-dashboard

1. No changes needed.

### pyrrha-simulator

1. Ensure the `Pyrrha-Sensor-Simulator/action/.env.docker` file exists and contains the following variables:

   ```bash
   IOT_HOST=pyrrha-mqttserver
   IOT_PROTOCOL=mqtt
   IOT_SECURE_PORT=1883
   ```

2. Copy `Pyrrha-Sensor-Simulator/action/devices.sample.json` into `Pyrrha-Sensor-Simulator/action/devices.json` and fill out the following information for each of your devices.

   - `IOT_CLIENTID`: a unique identifier for the device
   - `IOT_DEVICE_ID`: an identifier for the device. This is the "username" for this device. This field can be the same as `IOT_CLIENTID`
   - `IOT_PASSWORD`: a unique password for this device
   - IOT_FIREFIGHTER_ID: unique GUID like format. You can use a [service like this](https://duckduckgo.com/?q=generate+guid&ia=answer) to generate it.

   ```json
   {
     "IOT_CLIENTID": "device-id",
     "IOT_PASSWORD": "",
     "IOT_FIREFIGHTER_ID": "",
     "IOT_DEVICE_ID": "device-id"
   }
   ```

3. Using the Client ID, Password, and Device ID information from the last step, you will need to insert records into the `vmq_auth_acl` table referenced in the [pyrrha-mqttclient](#pyrrha-mqttclient) section. Follow the steps there to connect to the database to run the below insert statement. The inserts should be in the following format. Be sure to replace `CLIENTID`, `USERNAME`, and `PASSWORD` with the values for each device.

```sql
INSERT INTO vmq_auth_acl(mountpoint, client_id, username, password, publish_acl) VALUES ('', 'CLIENTID', 'USERNAME', SHA2('PASSWORD', 256), '[{"pattern":"iot-2/#"}]');
```

## Deployment

The following commands assume you are in the `pyrrha/Pyrrha-Deployment-Configurations` directory and have the Docker Desktop app running.

1. Run the `docker-compose build` command to build all the images. You should see the following output as the images are built one by one. The output has been truncated here for brevity.

   ```bash
   docker-compose build

   Building pyrrha-mariadb
   Step 1/2 : FROM docker.io/library/mariadb:10.3
   ---> 2ea064dffdcb
   Step 2/2 : ADD ./data/pyrrha.sql /docker-entrypoint-initdb.d
   ---> Using cache
   ---> 3680f6a57d6f

   Successfully built 3680f6a57d6f
   Successfully tagged pyrrha-mariadb:latest
   Building pyrrha-wss
   Step 1/12 : FROM docker.io/node:12-alpine
   ...
   ...
   ```

2. Run the `docker images | grep pyrrha` command to ensure all the images were built successfully.
3. Run the `docker-compose up` command to bring up all the services. You should see an output as follows: TBD
4. Run the `docker-compose ps` command to ensure all the containers are up and running.
5. You can access the dashboard at [`http://localhost:3000/`](http://localhost:3000/).
