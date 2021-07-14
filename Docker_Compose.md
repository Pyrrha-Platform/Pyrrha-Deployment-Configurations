# Deploy Pyrrha with Docker Compose

Docker Compose is a tool for defining and running multi-container Docker applications. The Pyrrha project consists of the following services. 

- **pyrrha-mariadb**: database that holds all the Pyrrha data
- **pyrrha-wss**: a websocket server
- **pyrrha-mqttclient**: service that sits between the IoT platform and other services
- **pyrrha-rulesdecision**: analytics service that calculates the time weighted averages of all data
- **pyrrha-api-main**: API backend for the dashboard
- **pyrrha-api-auth**: API backend used for authentication
- **pyrrha-dashboard:** dashboard that shows the real-time and long-term averages of firefighter exposure to toxic gases

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
      ```
      Docker version 19.03.13, build 4484c46d9d
      ```
- [Docker Compose](https://docs.docker.com/compose/install/)
  - Ensure you have docker installed by using `docker-compose --version` command. You should see output as follows:
      ```
      docker-compose version 1.27.4, build 40524192
      ```
### IBM Cloud
- Sign up for an [IBM Cloud account](https://cloud.ibm.com/registration).
- Create [IBM IoT service](https://github.com/Pyrrha-Platform/Pyrrha/blob/main/WATSON_IoT_SETUP.md) and copy the application credentials as [detailed here](https://github.com/Pyrrha-Platform/Pyrrha/blob/main/WATSON_IoT_SETUP.md).
- Create [IBM App ID service](https://cloud.ibm.com/catalog/services/app-id) and make note of the credentials.


## Configuration
1. Create a repository called `pyrrha`. This is where the rest of the code will be cloned.
   ```
   mkdir pyrrha && cd pyrrha
   ```
2. Clone all the required repositories.
   ```
   git clone https://github.com/Pyrrha-Platform/Pyrrha-Deployment-Configurations &&
   git clone https://github.com/Pyrrha-Platform/Pyrrha-Dashboard && 
   git clone https://github.com/Pyrrha-Platform/Pyrrha-WebSocket-Server &&
   git clone https://github.com/Pyrrha-Platform/Pyrrha-Rules-Decision &&
   git clone https://github.com/Pyrrha-Platform/Pyrrha-MQTT-Client &&
   git clone https://github.com/Pyrrha-Platform/Pyrrha-Database
   ```
3. Set MariaDB password in your terminal. This will be used with the rest of the instructions.
   ```
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
      - orgid in `IOT_HOST` and `IOT_CLIENTID`: see details on how to obtain orgid [here](https://github.com/Pyrrha-Platform/Pyrrha/blob/main/WATSON_IoT_SETUP.md#obtain-organization-id-from-the-iot-platform).
      - IOT_USERNAME: obtain from app credentials in the IoT platform. See details [here](https://github.com/Pyrrha-Platform/Pyrrha/blob/main/WATSON_IoT_SETUP.md#connect-an-application-to-ibm-watson-iot-platform).
      - IOT_PASSWORD: obtain from app credentials in the IoT platform. See details [here](https://github.com/Pyrrha-Platform/Pyrrha/blob/main/WATSON_IoT_SETUP.md#connect-an-application-to-ibm-watson-iot-platform).
   
      You can leave the rest of the values the same:

         ```
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
      ```
      MARIADB_HOST=pyrrha-mariadb
      MARIADB_PORT=3306
      MARIADB_USERNAME=root
      MARIADB_PASSWORD=$MDB_PASSWORD
      MARIADB_DB=pyrrha
      ```
      
      Leave the websocket server section as follows:
      ```
      WS_HOST=pyrrha-wss
      WS_PORT=8080
      ```
   2. Download messaging.pem file from [here](https://raw.githubusercontent.com/ibm-watson-iot/iot-python/master/src/wiotp/sdk/messaging.pem) into the root `Pyrrha-MQTT-Client` directory.
### pyrrha-rulesdecision
   1. Ensure the `Pyrrha-Rules-Decision/src/.env.docker` file contains the following variables:
      ```
      MARIADB_HOST=pyrrha-mariadb
      MARIADB_PORT=3306
      MARIADB_USERNAME=root
      MARIADB_PASSWORD=$MDB_PASSWORD
      MARIADB_DB=pyrrha
      ```
### pyrrha-api-main
   1. Ensure the `Pyrrha-Dashboard/pyrrha-dashboard/api-main/.env.docker` file contains the following variables:
      ```
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
      ```
      IOT_HOST=orgid.messaging.internetofthings.ibmcloud.com
      IOT_PROTOCOL=mqtts
      IOT_USERNAME=use-token-auth
      IOT_SECURE_PORT=8883
      IOT_PEM=messaging.pem
      ```
      Replace `orgid` with your IoT organization id.
   2. Download messaging.pem file from [here](https://raw.githubusercontent.com/ibm-watson-iot/iot-python/master/src/wiotp/sdk/messaging.pem) into the `Pyrrha-Sensor-Simulator/action` directory.
   3. Copy `Pyrrha-Sensor-Simulator/action/devices.sample.json` into `Pyrrha-Sensor-Simulator/action/devices.json` and fill out the information for your devices
## Deployment
The following commands assume you are in the `pyrrha/Pyrrha-Deployment-Configurations` directory.
1. Run the `docker-compose build` command to build all the images. You should see the following output as the images are built one by one. The output has been truncated here for brevity.
   ```
   ❯ docker-compose build    
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
5. You can access the dashboard at `http://localhost:3000/`.
