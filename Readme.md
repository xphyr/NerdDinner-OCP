# NERDDINNER OCP Example

This repo is a demo of taking an older MVC application and running it in a WINDOWS Container hosted in OpenShift using Windows Worker Nodes.

[NerdDinner](https://learn.microsoft.com/en-us/aspnet/mvc/overview/older-versions-1/nerddinner/introducing-the-nerddinner-tutorial) was originally hosted on CodePlex. I have made a copy of the code from [https://github.com/sixeyed/nerd-dinner](https://github.com/sixeyed/nerd-dinner) and am using this as the basis of this project. The C# code has not been changed at all from Sixeyed's copy of the code, which is listed as being an original copy of the code.

The intent is to show that using Windows containers it is possible to run code that goes back a few years.

## Requirements

* [Visual Studio 2022](https://visualstudio.microsoft.com/vs/compare/)
* OpenShift Container Platform 4.12+
	* Windows Machine Config Operator installed and working
* Windows 11 Machine with [Windows Containers configured](https://learn.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=dockerce#windows-10-and-11-1)
	* If you don't have a Windows 11 license, you can [Get a Windows 11 Development Environment](https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/), but you will need to enable Nested Virtualization within your VM platform
	* It is possible to install Docker for Windows without Docker Desktop. See [Windows Containers on Windows 10 or 11, without Docker Desktop](https://xphyr.net/post/windows_containers_win11/) for alternative install options.

## Building and Running the Container Locally

This example is written and tested using the mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2019 base container. 

To build the Windows container from a PowerShell terminal:

```
docker build -t nd .
```

To run the start the Nerd Dinner application container:

```
docker run --name nerddinner -p 8000:80 nd
```

Once the application has started, use a web browser to open http://localhost:8000.

## Running the NerdDinner application in OpenShift

This application can be run in an OpenShift cluster. Deployment files are located in the k8s directory. In order to run a Windows Container image you will need to have configured your cluster with the [Windows Machine Config Operator](https://docs.openshift.com/container-platform/4.13/windows_containers/index.html) and deployed at least one Windows Server node.

NerdDinner requires a Microsoft SQL Server database in order for the application to work. We will use the Linux based MS SQL Server container image to host the database to show that the overall application can be hosted by a mixture of both Linux and Windows nodes.

### Deploying the Database

We will need to pre-populate the database with the database schema and test data. In order to do this we will start by creating a new project (Namespace) in the OpenShift cluster. Once the project is created, we will create a database secret with the file `k8s/mssql-secret.yml`. If you want to use a different password, be sure to edit the mssql-secret.yml file before applying it.

```sh
$ oc new-project nerddinner
$ oc create -f k8s/mssql-secret.yml
```

### Deploy MS SQL in OpenShift

Deploy an ephemeral database from the mariadb-ephemeral template

MS SQL needs special permissions to run in OpenShift. We will create a SCC for this to run as:

```shell
$ oc create -f mssql/restrictedfsgroupsscc.yaml
$ oc adm policy add-scc-to-group restrictedfsgroup system:serviceaccounts:mssql
```

Now we will create some storage:

```shell
$ oc create -f storage.yaml
```

Finally we will deploy the database

```shell
$ oc create -f deployment.yaml
```

> **NOTE:** If you do not have persistent storage, you can deploy the MS SQL server with EmptyDir storage, but your database will not persist beyond the life of the pod. Substitute deployment-ephemeral.yaml in the above command to deploy using emptyDir.

### Populate the database

MS SQL does not give the opportunity to create a default database, so we need to create one. First we need to get the listing of running pods, then we will connect to the running instance with `oc rsh`

```shell
$ oc get po
NAME                                READY   STATUS    RESTARTS   AGE
guestbook-6db74c9d5d-pqc2q          1/1     Running   0          100m
mssql-deployment-56d5d6dd47-hkpmz   1/1     Running   0          2m5s
$ oc rsh mssql-deployment-56d5d6dd47-hkpmz
sh-4.4$ /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "NerdDinnerpass1!" -Q "CREATE DATABASE nerddinner"
sh-4.4$ /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "NerdDinnerpass1!" -Q "CREATE DATABASE nerddinnercontext"
sh-4.4$ /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "NerdDinnerpass1!" -Q "SELECT Name from sys.databases"
Name                                                                                                                            
--------------------------------------------------------------------------------------------------------------------------------
master                     
tempdb
model
msdb
nerddinner  
nerddinnercontext                                                                                                                     
(6 rows affected)
sh-4.4$ exit
```

#### Populate the database

The NerDinner application is not able to set up a blank database, we need to pupulate the database with some data and the schema. Follow the steps below do to this:

```shell
$ oc get po
NAME                                READY   STATUS    RESTARTS   AGE
guestbook-6db74c9d5d-pqc2q          1/1     Running   0          100m
mssql-deployment-56d5d6dd47-hkpmz   1/1     Running   0          2m5s
$ oc cp databaseFiles/nerddinner.sql mssql-deployment-56d5d6dd47-hkpmz:/tmp
$ oc cp databaseFiles/nerddinnercontext.sql mssql-deployment-56d5d6dd47-hkpmz:/tmp
$ oc rsh mssql-deployment-56d5d6dd47-hkpmz
sh-4.4$ /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "NerdDinnerpass1!" -i /tmp/nerddinnercontext.sql
sh-4.4$ /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "NerdDinnerpass1!" -i /tmp/nerddinner.sql
```

## Create webconfig file

We need to add some configuraton to our application now. Specifically, we need to add a [Bing Maps Key](https://learn.microsoft.com/en-us/bingmaps/getting-started/bing-maps-dev-center-help/getting-a-bing-maps-key) and we need to configure the username/password for our database instance we created earlier.

> Note: if you do not get a Bing API key, the maps will not render in the application.

Start be updating the `connectionStrings` settings to contain a valid connection string to connect to our database. In this case we are adding the service name for our MS-SQL database `mssql-service` and then our user name and password (in this case use the username/password that you configured in the [Deploying the database](#deploying-the-database) )

```XML
  <connectionStrings>
    <add name="DefaultConnection" connectionString="Data Source=mssql-service,1433\SQLEXPRESS;Initial Catalog=NerdDinner;User ID=SA;Password=NerdDinnerpass1!;" providerName="System.Data.SqlClient" />
    <add name="NerdDinnerContext" connectionString="Data Source=mssql-service,1433\SQLEXPRESS;Initial Catalog=NerdDinnerContext;User ID=SA;Password=NerdDinnerpass1!;" providerName="System.Data.SqlClient" />
  </connectionStrings>
```

Now update the `Web.config` file line 35 and add your Bing Maps API Key:

```XML
  <add key="BingMapsKey" value="<your key here>" />
```

Now update lines

```
 oc create secret generic webconfig --from-file Web.config
```