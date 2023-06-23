ARG BUILDER_IMAGE=mcr.microsoft.com/dotnet/framework/sdk:4.8
ARG RUNTIME_IMAGE=mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2019

FROM ${BUILDER_IMAGE} AS build
WORKDIR /app

# copy csproj and restore as distinct layers
COPY ./*.sln ./
COPY ./*.csproj ./
COPY ./*.config ./
RUN nuget restore

# copy everything else and build app
COPY . ./
RUN msbuild /p:Configuration=Release -r:False 

FROM ${RUNTIME_IMAGE} AS runtime
ARG LOGMON_URL=https://github.com/microsoft/windows-container-tools/releases/download/v1.2/LogMonitor.exe

# Install LogMonitor.exe
RUN mkdir /LogMonitor
ADD ${LOGMON_URL} /LogMonitor/LogMonitor.exe
COPY psscripts/LogMonitorConfig.json  /LogMonitor/

WORKDIR /inetpub/wwwroot

# copy bin directory
COPY --from=build /app/bin ./bin/

# copy status assets for the web application
COPY favicon.ico Global.asax packages.config Readme.md Web.config ./
COPY Content ./Content/
COPY Images ./Images/
COPY Scripts ./Scripts/
COPY Views ./Views/

# copy scripts
COPY psscripts/*.ps1 ./psscripts/

RUN .\psscripts\Set-WebConfigSettings.ps1 -webConfig C:\inetpub\wwwroot\Web.config

RUN Install-WindowsFeature "Web-Windows-Auth", "Web-Asp-Net45"

# SHELL ["C:\\LogMonitor\\LogMonitor.exe", "/CONFIG", "C:\\LogMonitor\\LogMonitorConfig.json", "powershell.exe"]
ENTRYPOINT ["C:\\LogMonitor\\LogMonitor.exe", "/CONFIG", "C:\\LogMonitor\\LogMonitorConfig.json", "C:\\ServiceMonitor.exe", "w3svc"]
