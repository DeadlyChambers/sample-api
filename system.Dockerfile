# https://hub.docker.com/_/microsoft-dotnet-sdk
FROM mcr.microsoft.com/dotnet/sdk:6.0.405 AS restore
WORKDIR /source
# copy csproj and restore as distinct layers
COPY . ./
ARG APP_VER
RUN dotnet restore system/system.csproj -r linux-x64 -p:Version="$APP_VER"

FROM restore as build
ARG APP_VER
RUN dotnet build system/system.csproj -c Release -r linux-x64 --no-restore --self-contained true -p:Version="$APP_VER"
# copy and publish app and libraries

#FROM build AS test
#RUN dotnet test tests/*.csproj --filter "TestCategory=Unit" --no-restore --logger trx -r /source/TestResults
#
#FROM scratch as export-test-results
#COPY --from=test /source/TestResults/*.trx .

FROM build as publish
ARG APP_VER
RUN dotnet publish system/system.csproj -c Release -r linux-x64 -o /app --self-contained true --no-build --no-restore -p:Version="$APP_VER"

# final stage/image
FROM mcr.microsoft.com/dotnet/runtime:6.0.13-jammy as deploy
WORKDIR /app
COPY --from=publish /app .
EXPOSE 80
ENTRYPOINT ["dotnet", "system.dll"]
