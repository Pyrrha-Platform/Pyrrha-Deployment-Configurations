# Deploy Pyrrha with Docker Compose

Docker Compose is a tool for defining and running multi-container Docker applications. The Pyrrha project consists of the following services.

- **pyrrha-mariadb**: database that holds all the Pyrrha data
- **pyrrha-wss**: a WebSocket server
- **pyrrha-mqttclient**: service that sits between the IoT platform and other services
- **pyrrha-rulesdecision**: analytics service that calculates the time weighted averages of all data
- **pyrrha-api-main**: API backend for the dashboard
- **pyrrha-api-auth**: API backend used for authentication
- **pyrrha-dashboard:** dashboard that shows the real-time and long-term averages of firefighter exposure to toxic gases

> Note: This environment does not set up the smartphone or watch apps.

The `docker-compose.yaml` file defines and configures all of these services.

- [Prerequisites](#prerequisites)
  - [Locally on your machine](#locally-on-your-machine)
  - [IBM Cloud](#ibm-cloud)
- [Configuration](#configuration)
  - [pyrrha-mariadb](#pyrrha-mariadb)
  - [pyrrha-wss](#pyrrha-wss)
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
  - Ensure you have docker installed by using `docker-compose --version` command. You should see output as follows:

    ```bash
    docker-compose version 1.27.4, build 40524192
    ```

### IBM Cloud

- Sign up for an [IBM Cloud account](https://cloud.ibm.com/registration).
- Create [IBM IoT service](https://github.com/Pyrrha-Platform/Pyrrha/blob/main/WATSON_IOT_SETUP.md) and copy the application credentials as [detailed here](https://github.com/Pyrrha-Platform/Pyrrha/blob/main/WATSON_IOT_SETUP.md).
- Create [IBM App ID service](https://cloud.ibm.com/catalog/services/app-id) and make note of the credentials.

## Configuration

1. Create a repository called `pyrrha`. This is where the rest of the code will be cloned.

   ```bash
   mkdir pyrrha && cd pyrrha
   ```

2. Clone all the required repositories.

   ```bash
   git clone https://github.com/Pyrrha-Platform/Pyrrha-Deployment-Configurations &&
   git clone https://github.com/Pyrrha-Platform/Pyrrha-Dashboard &&
   git clone https://github.com/Pyrrha-Platform/Pyrrha-WebSocket-Server &&
   git clone https://github.com/Pyrrha-Platform/Pyrrha-Rules-Decision &&
   git clone https://github.com/Pyrrha-Platform/Pyrrha-MQTT-Client &&
   git clone https://github.com/Pyrrha-Platform/Pyrrha-Database &&
   git clone https://github.com/Pyrrha-Platform/Pyrrha-Sensor-Simulator.git
   ```

3. Set MariaDB password in your terminal. This will be used with the rest of the instructions.

   ```bash
   export MDB_PASSWORD=example
   ```

   Optionally, you can add this line to `bashrc` or `.zshrc` file so it is automatically set whenever a terminal is opened.

Let's configure each of the services.

### pyrrha-mariadb

1. Ensure you set `MDB_PASSWORD` variable in the same terminal you will run the solution.

### pyrrha-wss

1. No additional configuration required

### pyrrha-mqttclient

1. Fill in the values in `Pyrrha-MQTT-Client/.env.docker` file. You need to fill out:

    - orgid in `IOT_HOST` and `IOT_CLIENTID`: see details on how to obtain orgid [here](https://github.com/Pyrrha-Platform/Pyrrha/blob/main/WATSON_IOT_SETUP.md#obtain-organization-id-from-the-iot-platform).
    - IOT_USERNAME: obtain from app credentials in the IoT platform. See details [here](https://github.com/Pyrrha-Platform/Pyrrha/blob/main/WATSON_IOT_SETUP.md#connect-an-application-to-ibm-watson-iot-platform).
    - IOT_PASSWORD: obtain from app credentials in the IoT platform. See details [here](https://github.com/Pyrrha-Platform/Pyrrha/blob/main/WATSON_IOT_SETUP.md#connect-an-application-to-ibm-watson-iot-platform).

    You can leave the rest of the values the same:

    ```bash
    # IBM IoT
    IOT_HOST=orgid.messaging.internetofthings.ibmcloud.com
    IOT_TOPIC=iot-2/type/+/id/+/evt/+/fmt/+
    IOT_PROTOCOL=mqtts
    IOT_USERNAME=
    IOT_PASSWORD=
    IOT_SECURE_PORT=8883
    IOT_PORT=1883
    IOT_CLIENTID=a:orgid:my_app
    IOT_PEM=messaging.pem
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

2. Download messaging.pem file from [here](https://raw.githubusercontent.com/ibm-watson-iot/iot-python/master/src/wiotp/sdk/messaging.pem) into the root `Pyrrha-MQTT-Client` directory.

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

2. Provision an AppID instance in IBM Cloud - https://cloud.ibm.com/catalog/services/app-id
3. Create AppID service credentials: In the newly created AppID instance, go to Service Credentials -> New credential. Set the role to `Writer`.
4. Expand the created credentials and fill in the required properties in your `vcap-local.json` file located in `web/api` under `AppID` and `credentials`. You can leave the `scopes` field as an empty array.
5. Copy the `apiKey` from your service credentials and add it to `vcap-local.json` in the `api_key` field under `ibm_cloud`.
6. `session_secret`: this can be any random string of characters.
7. `pyrrha_api_key`: this can be any random string of characters. This is used to send authenticated requests to the API.
8. `jwt_secret`: this can be any random string of characters.

### pyrrha-dashboard

1. No changes needed.

### pyrrha-simulator

1. Ensure the `Pyrrha-Sensor-Simulator/action/.env.docker` file exists and contains the following variables:

    ```bash
    IOT_HOST=orgid.messaging.internetofthings.ibmcloud.com
    IOT_PROTOCOL=mqtts
    IOT_USERNAME=use-token-auth
    IOT_SECURE_PORT=8883
    IOT_PEM=messaging.pem
    ```

    Replace `orgid` with your IoT organization id. See details on how to obtain orgid [here](https://github.com/Pyrrha-Platform/Pyrrha/blob/main/WATSON_IOT_SETUP.md#obtain-organization-id-from-the-iot-platform).

2. Download messaging.pem file from [here](https://raw.githubusercontent.com/ibm-watson-iot/iot-python/master/src/wiotp/sdk/messaging.pem) into the `Pyrrha-Sensor-Simulator/action` directory.

3. Copy `Pyrrha-Sensor-Simulator/action/devices.sample.json` into `Pyrrha-Sensor-Simulator/action/devices.json` and fill out the following information for each of your devices.
   - orgid in `IOT_CLIENTID`: see details on how to obtain orgid [here](https://github.com/Pyrrha-Platform/Pyrrha/blob/main/WATSON_IOT_SETUP.md#obtain-organization-id-from-the-iot-platform).
   - device-type in `IOT_CLIENTID`: type you assigned to the device on the IBM IoT platform. See [instructions](https://github.com/Pyrrha-Platform/Pyrrha/blob/main/WATSON_IOT_SETUP.md#connect-a-pyrrha-device-to-ibm-watson-iot-platform) for more details.
   - device-id in `IOT_CLIENTID`: is you assigned to the device on the IBM IoT platform. See [instructions](https://github.com/Pyrrha-Platform/Pyrrha/blob/main/WATSON_IOT_SETUP.md#connect-a-pyrrha-device-to-ibm-watson-iot-platform) for more details.
   - IOT_PASSWORD: the token that is generated for you when you add a new device. See details [here](https://github.com/Pyrrha-Platform/Pyrrha/blob/main/WATSON_IOT_SETUP.md#connect-a-pyrrha-device-to-ibm-watson-iot-platform).
   - IOT_FIREFIGHTER_ID: unique GUID like format. You can use a [service like this](https://duckduckgo.com/?q=generate+guid&ia=answer) to generate it.
   - IOT_DEVICE_ID: if you want to use the devices in the seed pyrrha database, use one of the following for each device: `Prometeo:00:00:00:00:00:01`, `Prometeo:00:00:00:00:00:02`, `Prometeo:00:00:00:00:00:03`, and `Prometeo:00:00:00:00:00:04`. These have been already filled out for you, but you can add more devices as well.

   ```json
   {
      "IOT_CLIENTID": "d:orgid:device-type:device-id",
      "IOT_PASSWORD": "",
      "IOT_FIREFIGHTER_ID": "",
      "IOT_DEVICE_ID": "device-id"
   }
   ```

## Deployment

The following commands assume you are in the `pyrrha/Pyrrha-Deployment-Configurations` directory.

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
