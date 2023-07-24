# escape=`

ARG BUILD_IMAGE=mcr.microsoft.com/dotnet/framework/sdk:4.8
ARG RUNTIME_IMAGE=mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2022

#
#  Runtime Stage:
#    - create custom runtime including LogMonitor
#

FROM $RUNTIME_IMAGE as runtime
ARG LOGMON_URL=https://github.com/microsoft/windows-container-tools/releases/download/v1.2/LogMonitor.exe

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install LogMonitor.exe
RUN mkdir /LogMonitor
ADD ${LOGMON_URL} /LogMonitor/LogMonitor.exe
COPY psscripts/LogMonitorConfig.json  /LogMonitor/

ENTRYPOINT ["C:\\LogMonitor\\LogMonitor.exe", "/CONFIG", "C:\\LogMonitor\\LogMonitorConfig.json", "C:\\ServiceMonitor.exe", "w3svc"]

#
# Build Stage:
#   - Copy source into container
#   - Restore packages using Nuget
#   - Build using MSBuild
#   - Publish artifacts to publish directory
#

FROM $BUILD_IMAGE AS build
WORKDIR /app

# copy csproj and restore as distinct layers
COPY ./*.sln ./
COPY ./*.config ./
COPY ./*.csproj ./
RUN nuget restore

# copy everything else and build app
COPY . ./
RUN msbuild /p:Configuration=Release -r:False

# copy
RUN mkdir publish
RUN cp -r favicon.ico,Global.asax,packages.config,Readme.md,Web.config,bin,Content,Images,Scripts,Views,psscripts publish

#
# Final Stage:
#   - Copy published artficats to /inetpub/wwwroot
#   - Start using LogMonitor
#

FROM runtime as Final
WORKDIR /inetpub/wwwroot

COPY --from=build /app/publish ./

RUN psscripts\Set-WebConfigSettings.ps1 -webConfig C:\inetpub\wwwroot\Web.config
