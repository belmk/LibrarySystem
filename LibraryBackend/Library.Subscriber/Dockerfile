# Base runtime image
FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copy project files for restore
COPY ["Library.Subscriber/Library.Subscriber.csproj", "Library.Subscriber/"]
COPY ["Library.Models/Library.Models.csproj", "Library.Models/"]
# Add other dependent projects if necessary

# Restore dependencies
RUN dotnet restore "Library.Subscriber/Library.Subscriber.csproj"

# Copy all source code
COPY . .

# Build the project
RUN dotnet build "Library.Subscriber/Library.Subscriber.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "Library.Subscriber/Library.Subscriber.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Final runtime image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Library.Subscriber.dll"]
