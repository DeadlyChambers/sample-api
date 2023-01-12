# https://hub.docker.com/_/microsoft-dotnet-sdk
FROM mcr.microsoft.com/dotnet/sdk:6.0.201-focal AS build
WORKDIR /app

# copy csproj and restore as distinct layers
# COPY . .
# ARG APP_VER
# RUN dotnet restore system/system.csproj -r linux-x64 -p:Version="$APP_VER"

#FROM restore as build
COPY . ./
ARG APP_VER
RUN dotnet build data/data.csproj -c Release -r linux-x64 --self-contained false -p:Version="$APP_VER"
# copy and publish app and libraries

FROM restore AS test
COPY . .
RUN dotnet test --filter "TestCategory=Unit" --no-restore --logger trx -r /app/TestResults

FROM scratch as export-test-results
COPY --from=test /app/TestResults/*.trx .

FROM build as publish
ARG APP_VER
RUN dotnet publish data/data.csproj -c Release -r linux-x64 -o /out --self-contained false --no-build --no-restore -p:Version="$APP_VER"

# final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:6.0.3-focal as final
WORKDIR /app
COPY --from=publish /out .
EXPOSE 80
ENTRYPOINT ["dotnet", "data.dll"]
