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
WORKDIR /inetpub/wwwroot
COPY --from=build /app/. ./