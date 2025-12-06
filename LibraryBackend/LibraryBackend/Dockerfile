# Base runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Ensure folder structure exists
RUN mkdir -p LibraryBackend Library.Services Library.Models

# Copy csproj files
COPY LibraryBackend/LibraryBackend.csproj LibraryBackend/
COPY Library.Services/Library.Services.csproj Library.Services/
COPY Library.Models/Library.Models.csproj Library.Models/

# Restore dependencies
RUN dotnet restore LibraryBackend/LibraryBackend.csproj

# Copy the rest of the source code
COPY . .

# Build project
RUN dotnet build LibraryBackend/LibraryBackend.csproj -c $BUILD_CONFIGURATION -o /app/build

# Publish stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish LibraryBackend/LibraryBackend.csproj -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Final runtime image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "LibraryBackend.dll"]
