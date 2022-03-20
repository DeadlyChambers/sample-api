# https://hub.docker.com/_/microsoft-dotnet-sdk
FROM mcr.microsoft.com/dotnet/sdk:6.0-focal AS restore
WORKDIR /app

# copy csproj and restore as distinct layers
COPY . .
RUN dotnet restore -r linux-x64

FROM restore as build
COPY . .
ARG APP_VER=6.0.2
RUN dotnet build system/system.csproj -c release -r linux-x64 --self-contained false --no-restore -p:Version="$APP_VER"
# copy and publish app and libraries

# FROM restore AS test
# COPY . .
# RUN dotnet test --filter "TestCategory=Unit" --no-restore --logger trx -r /app/TestResults

# FROM scratch as export-test-results
# COPY --from=test /app/TestResults/*.trx .

FROM build as publish
ARG APP_VER=6.0.2
RUN dotnet publish system/system.csproj -c release -r linux-x64 -o out --self-contained false --no-build -p:Version="$APP_VER"

# final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:6.0.1-focal
WORKDIR /app
COPY --from=publish /app/out .
EXPOSE 80
ENTRYPOINT ["dotnet", "system.dll"]
