# RUN ALL CONTAINERS FROM ROOT (folder with .sln file):
# docker-compose build
# docker-compose up
#
# RUN JUST THIS CONTAINER FROM ROOT (folder with .sln file):
# docker build --pull -t web -f src/Web/Dockerfile .
#
# RUN COMMAND
#  docker run --name eshopweb --rm -it -p 5106:5106 web
FROM microsoft/dotnet:2.2-sdk AS build
WORKDIR /app

COPY . .
WORKDIR /app/src/Web
RUN dotnet restore

RUN dotnet publish -c Release -o out

FROM microsoft/dotnet:2.2-aspnetcore-runtime AS runtime
WORKDIR /app
COPY --from=build /app/src/Web/out ./

# Optional: Set this here if not setting it from docker-compose.yml
# ENV ASPNETCORE_ENVIRONMENT Development
RUN groupadd -r devsecops && useradd --no-log-init -r -g devsecops devsecops
RUN mkdir /home/devsecops
RUN chown -R devsecops /app
RUN chown -R devsecops /home/devsecops
ENV ASPNETCORE_URLS=http://+:8080 
USER devsecops
ENTRYPOINT ["dotnet", "Web.dll", "--environment=development"]
