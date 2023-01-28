# https://hub.docker.com/_/microsoft-dotnet-sdk
FROM mcr.microsoft.com/dotnet/sdk:6.0.405 AS restore
WORKDIR /source
COPY . ./
ARG APP_VER
RUN dotnet restore data/data.csproj -r linux-x64 -p:Version="$APP_VER"

FROM restore as build
ARG APP_VER
RUN dotnet build data/data.csproj -c Release -r linux-x64 --no-restore --self-contained true -p:Version="$APP_VER"


#FROM restore AS test
#COPY . .
##ENV HOME=/root
#RUN dotnet test --filter "TestCategory=Unit" --no-restore --logger trx -r /source/TestResults
#
#FROM scratch as export-test-results
#COPY --from=test /source/TestResults/*.trx .

FROM build as publish
ARG APP_VER
RUN dotnet publish data/data.csproj -c Release -r linux-x64 -o /app --self-contained true --no-build --no-restore -p:Version="$APP_VER"

# final stage/image
FROM mcr.microsoft.com/dotnet/runtime:6.0.13-jammy as deploy
WORKDIR /app
COPY --from=publish /app .
EXPOSE 80
ENTRYPOINT ["dotnet", "data.dll"]
